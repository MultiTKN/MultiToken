pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "./ext/CheckedERC20.sol";
import "./ext/ERC1003Token.sol";
import "./interface/IBasicMultiToken.sol";


contract BasicMultiToken is Ownable, StandardToken, DetailedERC20, ERC1003Token, IBasicMultiToken {
    using CheckedERC20 for ERC20;
    using CheckedERC20 for DetailedERC20;

    ERC20[] public tokens;
    uint internal inLendingMode;
    bool public bundlingDenied;

    event Bundle(address indexed who, address indexed beneficiary, uint256 value);
    event Unbundle(address indexed who, address indexed beneficiary, uint256 value);
    event BundlingDenied(bool denied);

    modifier notInLendingMode {
        require(inLendingMode == 0, "Operation can't be performed while lending");
        _;
    }

    modifier bundlingEnabled {
        require(!bundlingDenied, "Operation can't be performed because bundling is denied");
        _;
    }

    constructor() public DetailedERC20("", "", 0) {
    }

    function init(ERC20[] _tokens, string _name, string _symbol, uint8 _decimals) public {
        require(decimals == 0, "init: contract was already initialized");
        require(_decimals > 0, "init: _decimals should not be zero");
        require(bytes(_name).length > 0, "init: _name should not be empty");
        require(bytes(_symbol).length > 0, "init: _symbol should not be empty");
        require(_tokens.length >= 2, "Contract do not support less than 2 inner tokens");

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        tokens = _tokens;
    }

    function bundleFirstTokens(address _beneficiary, uint256 _amount, uint256[] _tokenAmounts) public bundlingEnabled notInLendingMode {
        require(totalSupply_ == 0, "bundleFirstTokens: This method can be used with zero total supply only");
        _bundle(_beneficiary, _amount, _tokenAmounts);
    }

    function bundle(address _beneficiary, uint256 _amount) public bundlingEnabled notInLendingMode {
        require(totalSupply_ != 0, "This method can be used with non zero total supply only");
        uint256[] memory tokenAmounts = new uint256[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            tokenAmounts[i] = tokens[i].balanceOf(this).mul(_amount).div(totalSupply_);
        }
        _bundle(_beneficiary, _amount, tokenAmounts);
    }

    function unbundle(address _beneficiary, uint256 _value) public notInLendingMode {
        unbundleSome(_beneficiary, _value, tokens);
    }

    function unbundleSome(address _beneficiary, uint256 _value, ERC20[] _tokens) public notInLendingMode {
        require(_tokens.length > 0, "Array of tokens can't be empty");

        uint256 totalSupply = totalSupply_;
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply.sub(_value);
        emit Unbundle(msg.sender, _beneficiary, _value);
        emit Transfer(msg.sender, 0, _value);

        for (uint i = 0; i < _tokens.length; i++) {
            for (uint j = 0; j < i; j++) {
                require(_tokens[i] != _tokens[j], "unbundleSome: should not unbundle same token multiple times");
            }
            uint256 tokenAmount = _tokens[i].balanceOf(this).mul(_value).div(totalSupply);
            _tokens[i].checkedTransfer(_beneficiary, tokenAmount);
        }
    }

    // Admin methods

    function denyBundling() public onlyOwner {
        require(!bundlingDenied);
        bundlingDenied = true;
        emit BundlingDenied(true);
    }

    function allowBundling() public onlyOwner {
        require(bundlingDenied);
        bundlingDenied = false;
        emit BundlingDenied(false);
    }

    // Internal methods

    function _bundle(address _beneficiary, uint256 _amount, uint256[] _tokenAmounts) internal {
        require(_amount != 0, "Bundling amount should be non-zero");
        require(tokens.length == _tokenAmounts.length, "Lenghts of tokens and _tokenAmounts array should be equal");

        for (uint i = 0; i < tokens.length; i++) {
            require(_tokenAmounts[i] != 0, "Token amount should be non-zero");
            tokens[i].checkedTransferFrom(msg.sender, this, _tokenAmounts[i]); // Can't use require because not all ERC20 tokens return bool
        }

        totalSupply_ = totalSupply_.add(_amount);
        balances[_beneficiary] = balances[_beneficiary].add(_amount);
        emit Bundle(msg.sender, _beneficiary, _amount);
        emit Transfer(0, _beneficiary, _amount);
    }

    // Instant Loans

    function lend(address _to, ERC20 _token, uint256 _amount, address _target, bytes _data) public payable {
        uint256 prevBalance = _token.balanceOf(this);
        _token.asmTransfer(_to, _amount);
        inLendingMode += 1;
        require(caller_.makeCall.value(msg.value)(_target, _data), "lend: arbitrary call failed");
        inLendingMode -= 1;
        require(_token.balanceOf(this) >= prevBalance, "lend: lended token must be refilled");
    }

    // Public Getters

    function tokensCount() public view returns(uint) {
        return tokens.length;
    }

    function tokens(uint _index) public view returns(ERC20) {
        return tokens[_index];
    }

    function allTokens() public view returns(address[] _tokens) {
        _tokens = new address[](tokens.length);
        for (uint i = 0; i < _tokens.length; i++) {
            _tokens[i] = tokens[i];
        }
    }
}

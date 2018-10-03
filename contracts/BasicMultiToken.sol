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

    ERC20[] internal _tokens;
    uint internal _inLendingMode;
    bool internal _bundlingEnabled = true;

    event Bundle(address indexed who, address indexed beneficiary, uint256 value);
    event Unbundle(address indexed who, address indexed beneficiary, uint256 value);
    event BundlingStatus(bool enabled);

    modifier notInLendingMode {
        require(_inLendingMode == 0, "Operation can't be performed while lending");
        _;
    }

    modifier whenBundlingEnabled {
        require(_bundlingEnabled, "Bundling is disabled");
        _;
    }

    constructor() public DetailedERC20("", "", 0) {
    }

    function init(ERC20[] theTokens, string theName, string theSymbol, uint8 theDecimals) public {
        require(decimals == 0, "init: contract was already initialized");
        require(theDecimals > 0, "init: _decimals should not be zero");
        require(bytes(theName).length > 0, "init: _name should not be empty");
        require(bytes(theSymbol).length > 0, "init: _symbol should not be empty");
        require(theTokens.length >= 2, "Contract do not support less than 2 inner tokens");

        name = theName;
        symbol = theSymbol;
        decimals = theDecimals;
        _tokens = theTokens;
    }

    function tokensCount() public view returns(uint) {
        return _tokens.length;
    }

    function tokens(uint i) public view returns(ERC20) {
        return _tokens[i];
    }

    function bundleFirstTokens(address beneficiary, uint256 amount, uint256[] tokenAmounts) public whenBundlingEnabled notInLendingMode {
        require(totalSupply_ == 0, "bundleFirstTokens: This method can be used with zero total supply only");
        _bundle(beneficiary, amount, tokenAmounts);
    }

    function bundle(address beneficiary, uint256 amount) public whenBundlingEnabled notInLendingMode {
        require(totalSupply_ != 0, "This method can be used with non zero total supply only");
        uint256[] memory tokenAmounts = new uint256[](_tokens.length);
        for (uint i = 0; i < _tokens.length; i++) {
            tokenAmounts[i] = _tokens[i].balanceOf(this).mul(amount).div(totalSupply_);
        }
        _bundle(beneficiary, amount, tokenAmounts);
    }

    function unbundle(address beneficiary, uint256 value) public notInLendingMode {
        unbundleSome(beneficiary, value, _tokens);
    }

    function unbundleSome(address beneficiary, uint256 value, ERC20[] someTokens) public notInLendingMode {
        _unbundle(beneficiary, value, someTokens);
    }

    // Admin methods

    function disableBundling() public onlyOwner {
        require(_bundlingEnabled, "Bundling is already disabled");
        _bundlingEnabled = false;
        emit BundlingStatus(false);
    }

    function enableBundling() public onlyOwner {
        require(!_bundlingEnabled, "Bundling is already enabled");
        _bundlingEnabled = true;
        emit BundlingStatus(true);
    }

    // Internal methods

    function _bundle(address beneficiary, uint256 amount, uint256[] tokenAmounts) internal {
        require(amount != 0, "Bundling amount should be non-zero");
        require(_tokens.length == tokenAmounts.length, "Lenghts of _tokens and tokenAmounts array should be equal");

        for (uint i = 0; i < _tokens.length; i++) {
            require(tokenAmounts[i] != 0, "Token amount should be non-zero");
            _tokens[i].checkedTransferFrom(msg.sender, this, tokenAmounts[i]);
        }

        totalSupply_ = totalSupply_.add(amount);
        balances[beneficiary] = balances[beneficiary].add(amount);
        emit Bundle(msg.sender, beneficiary, amount);
        emit Transfer(0, beneficiary, amount);
    }

    function _unbundle(address beneficiary, uint256 value, ERC20[] someTokens) internal {
        require(someTokens.length > 0, "Array of someTokens can't be empty");

        uint256 totalSupply = totalSupply_;
        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply_ = totalSupply.sub(value);
        emit Unbundle(msg.sender, beneficiary, value);
        emit Transfer(msg.sender, 0, value);

        for (uint i = 0; i < someTokens.length; i++) {
            for (uint j = 0; j < i; j++) {
                require(someTokens[i] != someTokens[j], "unbundleSome: should not unbundle same token multiple times");
            }
            uint256 tokenAmount = someTokens[i].balanceOf(this).mul(value).div(totalSupply);
            someTokens[i].checkedTransfer(beneficiary, tokenAmount);
        }
    }

    // Instant Loans

    function lend(address to, ERC20 token, uint256 amount, address target, bytes data) public payable {
        uint256 prevBalance = token.balanceOf(this);
        token.asmTransfer(to, amount);
        _inLendingMode += 1;
        require(caller_.makeCall.value(msg.value)(target, data), "lend: arbitrary call failed");
        _inLendingMode -= 1;
        require(token.balanceOf(this) >= prevBalance, "lend: lended token must be refilled");
    }
}

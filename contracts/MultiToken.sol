pragma solidity ^0.4.24;

import "./ext/CheckedERC20.sol";
import "./interface/IMultiToken.sol";
import "./BasicMultiToken.sol";


contract MultiToken is IMultiToken, BasicMultiToken {
    using CheckedERC20 for ERC20;

    uint256 internal minimalWeight;
    bool public changesDenied;

    event ChangesDenied();

    modifier changesEnabled {
        require(!changesDenied, "Operation can't be performed because changes are denied");
        _;
    }

    function init(ERC20[] _tokens, uint256[] _weights, string _name, string _symbol, uint8 _decimals) public {
        super.init(_tokens, _name, _symbol, _decimals);
        require(_weights.length == tokens.length, "Lenghts of _tokens and _weights array should be equal");
        for (uint i = 0; i < tokens.length; i++) {
            require(_weights[i] != 0, "The _weights array should not contains zeros");
            require(weights[tokens[i]] == 0, "The _tokens array have duplicates");
            weights[tokens[i]] = _weights[i];
            if (minimalWeight == 0 || _weights[i] < minimalWeight) {
                minimalWeight = _weights[i];
            }
        }
    }

    function init2(ERC20[] _tokens, uint256[] _weights, string _name, string _symbol, uint8 _decimals) public {
        init(_tokens, _weights, _name, _symbol, _decimals);
    }

    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns(uint256 returnAmount) {
        if (weights[_fromToken] > 0 && weights[_toToken] > 0 && _fromToken != _toToken) {
            uint256 fromBalance = ERC20(_fromToken).balanceOf(this);
            uint256 toBalance = ERC20(_toToken).balanceOf(this);
            returnAmount = _amount.mul(toBalance).mul(weights[_fromToken]).div(
                _amount.mul(weights[_fromToken]).div(minimalWeight).add(fromBalance).mul(weights[_toToken])
            );
        }
    }

    function change(address _fromToken, address _toToken, uint256 _amount, uint256 _minReturn) public changesEnabled notInLendingMode returns(uint256 returnAmount) {
        returnAmount = getReturn(_fromToken, _toToken, _amount);
        require(returnAmount > 0, "The return amount is zero");
        require(returnAmount >= _minReturn, "The return amount is less than _minReturn value");

        ERC20(_fromToken).checkedTransferFrom(msg.sender, this, _amount);
        ERC20(_toToken).checkedTransfer(msg.sender, returnAmount);

        emit Change(_fromToken, _toToken, msg.sender, _amount, returnAmount);
    }

    // Admin methods

    function denyChanges() public onlyOwner {
        require(!changesDenied);
        changesDenied = true;
        emit ChangesDenied();
    }
}

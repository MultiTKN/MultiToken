pragma solidity ^0.4.24;

import "./ext/CheckedERC20.sol";
import "./interface/IMultiToken.sol";
import "./BasicMultiToken.sol";


contract MultiToken is IMultiToken, BasicMultiToken {
    using CheckedERC20 for ERC20;

    mapping(address => uint256) private _weights;
    uint256 internal _minimalWeight;
    bool private _changesEnabled = true;

    event ChangesDisabled();

    modifier whenChangesEnabled {
        require(_changesEnabled, "Operation can't be performed because changes are disabled");
        _;
    }

    function weights(address _token) public view returns(uint256) {
        return _weights[_token];
    }

    function changesEnabled() public view returns(bool) {
        return _changesEnabled;
    }

    constructor(ERC20[] tokens, uint256[] tokenWeights, string name, string symbol, uint8 decimals) 
        public BasicMultiToken(tokens, name, symbol, decimals)
    {
        require(tokenWeights.length == tokens.length, "Lenghts of tokens and tokenWeights array should be equal");

        uint256 minimalWeight = 0;
        for (uint i = 0; i < tokens.length; i++) {
            require(tokenWeights[i] != 0, "The tokenWeights array should not contains zeros");
            require(_weights[tokens[i]] == 0, "The tokens array have duplicates");
            _weights[tokens[i]] = tokenWeights[i];
            if (minimalWeight == 0 || tokenWeights[i] < minimalWeight) {
                minimalWeight = tokenWeights[i];
            }
        }
        _minimalWeight = minimalWeight;
    }

    function getReturn(address fromToken, address toToken, uint256 amount) public view returns(uint256 returnAmount) {
        if (_weights[fromToken] > 0 && _weights[toToken] > 0 && fromToken != toToken) {
            uint256 fromBalance = ERC20(fromToken).balanceOf(this);
            uint256 toBalance = ERC20(toToken).balanceOf(this);
            returnAmount = amount.mul(toBalance).mul(_weights[fromToken]).div(
                amount.mul(_weights[fromToken]).div(_minimalWeight).add(fromBalance).mul(_weights[toToken])
            );
        }
    }

    function change(address fromToken, address toToken, uint256 amount, uint256 minReturn) public whenChangesEnabled notInLendingMode returns(uint256 returnAmount) {
        returnAmount = getReturn(fromToken, toToken, amount);
        require(returnAmount > 0, "The return amount is zero");
        require(returnAmount >= minReturn, "The return amount is less than minReturn value");

        ERC20(fromToken).checkedTransferFrom(msg.sender, this, amount);
        ERC20(toToken).checkedTransfer(msg.sender, returnAmount);

        emit Change(fromToken, toToken, msg.sender, amount, returnAmount);
    }

    // Admin methods

    function disableChanges() public onlyOwner {
        require(_changesEnabled, "Changes are already disabled");
        _changesEnabled = false;
        emit ChangesDisabled();
    }

    // Internal methods

    function setWeight(address token, uint256 newWeight) internal {
        _weights[token] = newWeight;
    }
}

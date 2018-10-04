pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./MultiToken.sol";


contract OwnableMultiTokenMixin is Ownable, MultiToken {
    //
}


contract ManagealbleOrOwnableMultiTokenMixin is OwnableMultiTokenMixin {
    // solium-disable-next-line security/no-tx-origin
    address private _manager = tx.origin;

    modifier onlyManager {
        require(msg.sender == _manager, "Access denied");
        _;
    }

    modifier onlyOwnerOrManager {
        require(msg.sender == owner || msg.sender == _manager, "Access denied");
        _;
    }

    function manager() public view returns(address) {
        return _manager;
    }

    function transferManager(address newManager) public onlyManager {
        require(newManager != address(0), "newManager can't be zero address");
        _manager = newManager;
    }
}


contract LockableMultiTokenMixin is ManagealbleOrOwnableMultiTokenMixin {
    mapping(address => bool) private _tokenIsLocked;

    function lockToken(address token) public onlyOwnerOrManager {
        _tokenIsLocked[token] = true;
    }

    function tokenIsLocked(address token) public view returns(bool) {
        return _tokenIsLocked[token];
    }

    function getReturn(address fromToken, address toToken, uint256 amount) public view returns(uint256 returnAmount) {
        if (!_tokenIsLocked[fromToken] && !_tokenIsLocked[toToken]) {
            returnAmount = super.getReturn(fromToken, toToken, amount);
        }
    }

    function change(address fromToken, address toToken, uint256 amount, uint256 minReturn) public returns(uint256 returnAmount) {
        require(!_tokenIsLocked[fromToken], "The _fromToken is locked for exchange by multitoken owner");
        require(!_tokenIsLocked[toToken], "The _toToken is locked for exchange by multitoken owner");
        returnAmount = super.change(fromToken, toToken, amount, minReturn);
    }
}


contract FundMultiToken is LockableMultiTokenMixin {
    mapping(address => uint256) private _nextWeights;
    uint256 private _nextMinimalWeight;
    uint256 private _nextWeightStartBlock;
    uint256 private _nextWeightBlockDelay = 100;
    uint256 private _nextWeightBlockDelayUpdate;

    event WeightsChanged(uint256 startingBlockNumber, uint256 endingBlockNumber, uint256 _nextWeightBlockDelay);

    function nextWeights(address token) public view returns(uint256) {
        return _nextWeights[token];
    }

    function nextWeightStartBlock() public view returns(uint256) {
        return _nextWeightStartBlock;
    }

    function nextWeightBlockDelay() public view returns(uint256) {
        return _nextWeightBlockDelay;
    }

    function weights(address token) public view returns(uint256) {
        if (_nextWeightStartBlock == 0) {
            return weights(token);
        }

        uint256 blockProgress = block.number - _nextWeightStartBlock;
        if (blockProgress < _nextWeightBlockDelay) {
            linearInterpolation(weights(token), _nextWeights[token], blockProgress, _nextWeightBlockDelay);
        }
        return _nextWeights[token];
    }

    function setNextWeightBlockDelay(uint256 theNextWeightBlockDelay) public onlyOwner {
        if (block.number > _nextWeightStartBlock.add(_nextWeightBlockDelay)) {
            _nextWeightBlockDelay = theNextWeightBlockDelay;
        } else {
            _nextWeightBlockDelayUpdate = theNextWeightBlockDelay;
        }
    }

    function changeWeights(uint256[] theNextWeights) public onlyManager {
        require(theNextWeights.length == tokensCount(), "theNextWeights array length should match tokens length");
        require(block.number.sub(_nextWeightStartBlock) > _nextWeightBlockDelay, "Previous weights changed is not completed yet");

        // Migrate previous weights
        if (_nextWeightStartBlock != 0) {
            for (uint i = 0; i < tokensCount(); i++) {
                setWeight(tokens(i), _nextWeights[tokens(i)]);
            }
            _minimalWeight = _nextMinimalWeight;
            if (_nextWeightBlockDelayUpdate > 0) {
                _nextWeightBlockDelay = _nextWeightBlockDelayUpdate;
                _nextWeightBlockDelayUpdate = 0;
            }
        }

        _nextMinimalWeight = 0;
        _nextWeightStartBlock = block.number;
        for (i = 0; i < tokensCount(); i++) {
            require(theNextWeights[i] != 0, "The theNextWeights array should not contains zeros");
            _nextWeights[tokens(i)] = theNextWeights[i];
            if (_nextMinimalWeight == 0 || theNextWeights[i] < _nextMinimalWeight) {
                _nextMinimalWeight = theNextWeights[i];
            }
        }
    }

    function getReturn(address fromToken, address toToken, uint256 amount) public view returns(uint256) {        
        if (fromToken == toToken) {
            return 0;
        }
        
        uint256 blockProgress = block.number - _nextWeightStartBlock;
        uint256 scaledFromWeight = _minimalWeight;
        uint256 scaledToWeight = weights(fromToken);
        uint256 scaledMinWeight = weights(toToken);
        if (blockProgress < _nextWeightBlockDelay) {
            scaledFromWeight = linearInterpolation(weights(fromToken), _nextWeights[fromToken], blockProgress, _nextWeightBlockDelay);
            scaledToWeight = linearInterpolation(weights(toToken), _nextWeights[toToken], blockProgress, _nextWeightBlockDelay);
            scaledMinWeight = linearInterpolation(_minimalWeight, _nextMinimalWeight, blockProgress, _nextWeightBlockDelay);
        }

        // uint256 fromBalance = ERC20(fromToken).balanceOf(this);
        // uint256 toBalance = ERC20(toToken).balanceOf(this);
        return amount.mul(ERC20(toToken).balanceOf(this)).mul(scaledFromWeight).div(
            amount.mul(scaledFromWeight).div(scaledMinWeight).add(ERC20(fromToken).balanceOf(this)).mul(scaledToWeight)
        );
    }

    function change(address fromToken, address toToken, uint256 amount, uint256 minReturn) public whenChangesEnabled notInLendingMode returns(uint256) {
        if (block.number > _nextWeightStartBlock.add(_nextWeightBlockDelay)) {
            _nextWeightStartBlock = 0;
        }
        return super.change(fromToken, toToken, amount, minReturn);
    }

    function _bundle(address beneficiary, uint256 amount, uint256[] tokenAmounts) internal {
        if (totalSupply_ > 0) {
            _nextWeightBlockDelay = _nextWeightBlockDelay.mul(totalSupply_.add(amount)).div(totalSupply_);
        } else {
            _nextWeightBlockDelay = 100;
        }
        return super._bundle(beneficiary, amount, tokenAmounts);
    }

    function _unbundle(address beneficiary, uint256 value, ERC20[] someTokens) internal {
        if (totalSupply_ > value) {
            _nextWeightBlockDelay = _nextWeightBlockDelay.mul(totalSupply_.sub(value)).div(totalSupply_);
        } else {
            _nextWeightBlockDelay = 100;
        }
        return super._unbundle(beneficiary, value, someTokens);
    }

    function linearInterpolation(uint256 a, uint256 b, uint256 _mul, uint256 _notDiv) internal pure returns(uint256) {
        if (a < b) {
            return a.mul(_notDiv).add(b.sub(a).mul(_mul));
        }
        return b.mul(_notDiv).add(a.sub(b).mul(_mul));
    }
}

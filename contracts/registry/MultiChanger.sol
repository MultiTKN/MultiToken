pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "../interface/IMultiToken.sol";

contract IBancorNetwork {
    function claimAndConvert(
        address[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) 
        public
        payable
        returns(uint256);
}

contract IKyberNetworkProxy {
    function trade(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
        public
        payable
        returns(uint);
}


contract MultiChanger is CanReclaimToken {
    using SafeMath for uint256;

    function subbytes(bytes _data, uint _start, uint _length) internal pure returns(bytes) {
        bytes memory result = new bytes(_length);
        for (uint i = 0; i < _length; i++) {
            result[i] = _data[_start + i];
        }
        return result;
    }

    function change(
        address[] _exchanges,
        bytes _datas,
        uint[] _datasIndexes, // including 0 and LENGTH values
        uint256[] _fractions, // x.mul(high 128bit).div(low 128bit)
        uint256[] _throughTokens
    )
        internal
    {
        require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
        require(_fractions.length == _exchanges.length, "buy: _fractions should have the same length as _exchanges");

        for (uint i = 0; i < _exchanges.length; i++) {
            bytes memory data;
            if (_throughTokens[i] >> 224 == 0) {
                data = subbytes(_datas, _datasIndexes[i], _datasIndexes[i + 1] - _datasIndexes[i]);
                convertEthToToken(_exchanges[i], data, _fractions[i]);
            } else
            if (_throughTokens[i] >> 224 == 1) {
                data = subbytes(_datas, _datasIndexes[i], _datasIndexes[i + 1] - _datasIndexes[i]);
                convertTokenToAny_onApprove(_exchanges[i], data, ERC20(_throughTokens[i]), _fractions[i]);
            } else
            if (_throughTokens[i] >> 224 == 2) {
                data = subbytes(_datas, _datasIndexes[i], _datasIndexes[i + 1] - _datasIndexes[i]);
                convertTokenToAny_onTransfer(_exchanges[i], data, ERC20(_throughTokens[i]), _fractions[i]);
            } else
            if (_throughTokens[i] >> 224 == 100) {
                bancorTokenToAny_onApprove(IBancorNetwork(_exchanges[i]), _datas, _datasIndexes[i], ERC20(_throughTokens[i]), _fractions[i]);
            } else
            if (_throughTokens[i] >> 224 == 101) {
                bancorTokenToAny_onTransfer(IBancorNetwork(_exchanges[i]), _datas, _datasIndexes[i], ERC20(_throughTokens[i]), _fractions[i]);
            } else
            if (_throughTokens[i] >> 224 == 201) {
                kyberTokenToAny_onApprove(IKyberNetworkProxy(_exchanges[i]), _datas, _datasIndexes[i], ERC20(_throughTokens[i]), _fractions[i]);
            }
        }
    }

    function convertEthToToken(address _target, bytes _data, uint256 _value2) internal {
        uint256 value = address(this).balance.mul(_value2 >> 128).div((_value2 << 128) >> 128);
        require(_target.call.value(value)(_data));
    }

    function convertTokenToAny_onApprove(address _target, bytes _data, ERC20 _fromToken, uint256 _value2) internal {
        _value2; // unused
        if (_fromToken.allowance(this, _target) == 0) {
            _fromToken.approve(_target, uint256(-1));
        }
        require(_target.call(_data));
    }

    function convertTokenToAny_onTransfer(address _target, bytes _data, ERC20 _fromToken, uint256 _value2) internal {
        uint256 amount = _fromToken.balanceOf(this).mul(_value2 >> 128).div((_value2 << 128) >> 128);
        _fromToken.transfer(_target, amount);
        require(_target.call(_data));
    }

    function bancorTokenToAny_onApprove(IBancorNetwork _bancor, bytes _data, uint _offset, ERC20 _fromToken, uint256 _value2) internal {
        uint256 amount = _fromToken.balanceOf(this).mul(_value2 >> 128).div((_value2 << 128) >> 128);
        if (_fromToken.allowance(this, _bancor) == 0) {
            _fromToken.approve(_bancor, uint256(-1));
        }
        bancorTokenToAny(_bancor, _data, _offset, _fromToken, amount);
    }

    function bancorTokenToAny_onTransfer(IBancorNetwork _bancor, bytes _data, uint _offset, ERC20 _fromToken, uint256 _value2) internal {
        uint256 amount = _fromToken.balanceOf(this).mul(_value2 >> 128).div((_value2 << 128) >> 128);
        _fromToken.transfer(_bancor, amount);
        bancorTokenToAny(_bancor, _data, _offset, _fromToken, amount);
    }

    function kyberTokenToAny_onApprove(IKyberNetworkProxy _kyber, bytes _data, uint _offset, ERC20 _fromToken, uint256 _value2) internal {
        uint256 amount = _fromToken.balanceOf(this).mul(_value2 >> 128).div((_value2 << 128) >> 128);
        if (_fromToken.allowance(this, _kyber) == 0) {
            _fromToken.approve(_kyber, uint256(-1));
        }
        kyberTokenToAny(_kyber, _data, _offset, _fromToken, amount);
    }

    // function kyberTokenToAny_onTransfer(IKyberNetworkProxy _kyber, bytes _data, uint _offset, ERC20 _fromToken, uint256 _value2) internal {
    //     uint256 amount = _fromToken.balanceOf(this).mul(_value2 >> 128).div((_value2 << 128) >> 128);
    //     _fromToken.transfer(_kyber, amount);
    //     kyberTokenToAny(_kyber, _data, _offset, _fromToken, amount);
    // }

    // Private methods

    function bancorTokenToAny(IBancorNetwork _bancor, bytes _data, uint _dataStart, ERC20 _fromToken, uint256 _amount) private {
        uint256 converter = 0;
        uint256 toToken = 0;
        assembly {
            converter := mload(add(_data, add(_dataStart, 0x20)))
            toToken := mload(add(_data, add(_dataStart, 0x40)))
        }

        address[] memory path = new address[](3);
        path[0] = _fromToken;
        path[1] = address(converter);
        path[2] = address(toToken);

        _bancor.claimAndConvert(
            path,
            _amount,
            1
        );
    }

    function kyberTokenToAny(IKyberNetworkProxy _kyber, bytes _data, uint _dataStart, ERC20 _fromToken, uint256 _amount) private {
        uint256 toToken = 0;
        assembly {
            toToken := mload(add(_data, add(_dataStart, 0x20)))
        }

        _kyber.trade(
            _fromToken,
            _amount,
            ERC20(toToken),
            this,
            1 << 255,
            0,
            0
        );
    }
}

pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import { IMultiToken } from "../interface/IMultiToken.sol";
import "../ext/CheckedERC20.sol";
import "./MultiChanger.sol";


contract MultiSeller is MultiChanger {
    using CheckedERC20 for ERC20;
    using CheckedERC20 for IMultiToken;

    function() public payable {
        // solium-disable-next-line security/no-tx-origin
        require(tx.origin != msg.sender);
    }

    function sellForOrigin(
        IMultiToken _mtkn,
        uint256 _amount,
        bytes _callDatas,
        uint[] _starts // including 0 and LENGTH values
    )
        public
    {
        sell(
            _mtkn,
            _amount,
            _callDatas,
            _starts,
            tx.origin   // solium-disable-line security/no-tx-origin
        );
    }

    function sell(
        IMultiToken _mtkn,
        uint256 _amount,
        bytes _callDatas,
        uint[] _starts, // including 0 and LENGTH values
        address _for
    )
        public
    {
        _mtkn.asmTransferFrom(msg.sender, this, _amount);
        _mtkn.unbundle(this, _amount);
        change(_callDatas, _starts);
        _for.transfer(address(this).balance);
    }

    // DEPRECATED:

    function sellOnApproveForOrigin(
        IMultiToken _mtkn,
        uint256 _amount,
        ERC20 _throughToken,
        address[] _exchanges,
        bytes _datas,
        uint[] _datasIndexes // including 0 and LENGTH values
    )
        public
    {
        sellOnApprove(
            _mtkn,
            _amount,
            _throughToken,
            _exchanges,
            _datas,
            _datasIndexes,
            tx.origin
        );
    }

    function sellOnApprove(
        IMultiToken _mtkn,
        uint256 _amount,
        ERC20 _throughToken,
        address[] _exchanges,
        bytes _datas,
        uint[] _datasIndexes, // including 0 and LENGTH values
        address _for
    )
        public
    {
        if (_throughToken == address(0)) {
            require(_mtkn.tokensCount() == _exchanges.length, "sell: _mtkn should have the same tokens count as _exchanges");
        } else {
            require(_mtkn.tokensCount() + 1 == _exchanges.length, "sell: _mtkn should have tokens count + 1 equal _exchanges length");
        }
        require(_datasIndexes.length == _exchanges.length + 1, "sell: _datasIndexes should start with 0 and end with LENGTH");

        _mtkn.transferFrom(msg.sender, this, _amount);
        _mtkn.unbundle(this, _amount);

        for (uint i = 0; i < _exchanges.length; i++) {
            bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
            for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
                data[j - _datasIndexes[i]] = _datas[j];
            }
            if (data.length == 0) {
                continue;
            }

            if (i == _exchanges.length - 1 && _throughToken != address(0)) {
                if (_throughToken.allowance(this, _exchanges[i]) == 0) {
                    _throughToken.asmApprove(_exchanges[i], uint256(-1));
                }
            } else {
                ERC20 token = _mtkn.tokens(i);
                if (_exchanges[i] == 0) {
                    token.asmTransfer(_for, token.balanceOf(this));
                    continue;
                }
                token.asmApprove(_exchanges[i], token.balanceOf(this));
            }
            require(_exchanges[i].call(data), "sell: exchange arbitrary call failed");
        }

        _for.transfer(address(this).balance);
        if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
            _throughToken.asmTransfer(_for, _throughToken.balanceOf(this));
        }
    }
}

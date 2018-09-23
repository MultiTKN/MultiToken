pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import { IMultiToken } from "../interface/IMultiToken.sol";
import "../ext/CheckedERC20.sol";
import "./MultiChanger.sol";


contract MultiSeller is MultiChanger {
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
}

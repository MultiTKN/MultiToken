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
        require(tx.origin != msg.sender);
    }

    function sellForOrigin(
        IMultiToken _mtkn,
        uint256 _amount,
        address[] _exchanges,
        bytes _datas,
        uint[] _datasIndexes, // including 0 and LENGTH values
        uint256[] _fractions,
        uint256[] _throughTokens
    )
        public
    {
        sell(
            _mtkn,
            _amount,
            _exchanges,
            _datas,
            _datasIndexes,
            _fractions,
            _throughTokens,
            tx.origin
        );
    }

    function sell(
        IMultiToken _mtkn,
        uint256 _amount,
        address[] _exchanges,
        bytes _datas,
        uint[] _datasIndexes, // including 0 and LENGTH values
        uint256[] _fractions,
        uint256[] _throughTokens,
        address _for
    )
        public
    {
        _mtkn.transferFrom(msg.sender, this, _amount);
        _mtkn.unbundle(this, _amount);
        change(_exchanges, _datas, _datasIndexes, _fractions, _throughTokens);
        _for.transfer(address(this).balance);
    }
}

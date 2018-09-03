pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../interface/IMultiToken.sol";
import "./MultiChanger.sol";

contract MultiBuyer is MultiChanger {
    function buy(
        IMultiToken _mtkn,
        uint256 _minimumReturn,
        uint256[] _throughTokens,
        address[] _exchanges,
        bytes _datas,
        uint[] _datasIndexes, // including 0 and LENGTH values
        uint256[] _fractions
    )
        public
        payable
    {
        change(_exchanges, _datas, _datasIndexes, _fractions, _throughTokens);

        uint mtknTotalSupply = _mtkn.totalSupply(); // optimization totalSupply
        uint256 bestAmount = uint256(-1);
        for (uint i = _mtkn.tokensCount(); i > 0; i--) {
            ERC20 token = _mtkn.tokens(i - 1);
            if (token.allowance(this, _mtkn) == 0) {
                token.approve(_mtkn, uint256(-1));
            }

            uint256 amount = mtknTotalSupply.mul(token.balanceOf(this)).div(token.balanceOf(_mtkn));
            if (amount < bestAmount) {
                bestAmount = amount;
            }
        }

        require(bestAmount >= _minimumReturn, "buy: return value is too low");
        _mtkn.bundle(msg.sender, bestAmount);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = _mtkn.tokensCount(); i > 0; i--) {
            token = _mtkn.tokens(i - 1);
            token.transfer(msg.sender, token.balanceOf(this));
        }
    }

    function buyFirstTokens(
        IMultiToken _mtkn,
        uint256[] _throughTokens,
        address[] _exchanges,
        bytes _datas,
        uint[] _datasIndexes, // including 0 and LENGTH values
        uint256[] _fractions
    )
        public
        payable
    {
        change(_exchanges, _datas, _datasIndexes, _fractions, _throughTokens);

        uint tokensCount = _mtkn.tokensCount();
        uint256[] memory amounts = new uint256[](tokensCount);
        for (uint i = 0; i < tokensCount; i++) {
            ERC20 token = _mtkn.tokens(i);
            amounts[i] = token.balanceOf(this);
            if (token.allowance(this, _mtkn) == 0) {
                token.approve(_mtkn, uint256(-1));
            }
        }

        _mtkn.bundleFirstTokens(msg.sender, msg.value.mul(1000), amounts);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = _mtkn.tokensCount(); i > 0; i--) {
            token = _mtkn.tokens(i - 1);
            token.transfer(msg.sender, token.balanceOf(this));
        }
    }
}

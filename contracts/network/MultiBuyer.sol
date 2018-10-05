pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../interface/IMultiToken.sol";
import "../ext/CheckedERC20.sol";
import "./MultiChanger.sol";


contract MultiBuyer is MultiChanger {
    using CheckedERC20 for ERC20;

    function buy(
        IMultiToken mtkn,
        uint256 minimumReturn,
        bytes callDatas,
        uint[] starts // including 0 and LENGTH values
    )
        public
        payable
    {
        change(callDatas, starts);

        uint mtknTotalSupply = mtkn.totalSupply(); // optimization totalSupply
        uint256 bestAmount = uint256(-1);
        for (uint i = mtkn.tokensCount(); i > 0; i--) {
            ERC20 token = mtkn.tokens(i - 1);
            if (token.allowance(this, mtkn) == 0) {
                token.asmApprove(mtkn, uint256(-1));
            }

            uint256 amount = mtknTotalSupply.mul(token.balanceOf(this)).div(token.balanceOf(mtkn));
            if (amount < bestAmount) {
                bestAmount = amount;
            }
        }

        require(bestAmount >= minimumReturn, "buy: return value is too low");
        mtkn.bundle(msg.sender, bestAmount);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = mtkn.tokensCount(); i > 0; i--) {
            token = mtkn.tokens(i - 1);
            if (token.balanceOf(this) > 0) {
                token.asmTransfer(msg.sender, token.balanceOf(this));
            }
        }
    }

    function buyFirstTokens(
        IMultiToken mtkn,
        bytes callDatas,
        uint[] starts // including 0 and LENGTH values
    )
        public
        payable
    {
        change(callDatas, starts);

        uint tokensCount = mtkn.tokensCount();
        uint256[] memory amounts = new uint256[](tokensCount);
        for (uint i = 0; i < tokensCount; i++) {
            ERC20 token = mtkn.tokens(i);
            amounts[i] = token.balanceOf(this);
            if (token.allowance(this, mtkn) == 0) {
                token.asmApprove(mtkn, uint256(-1));
            }
        }

        mtkn.bundleFirstTokens(msg.sender, msg.value.mul(100), amounts);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = mtkn.tokensCount(); i > 0; i--) {
            token = mtkn.tokens(i - 1);
            if (token.balanceOf(this) > 0) {
                token.asmTransfer(msg.sender, token.balanceOf(this));
            }
        }
    }

    // DEPRECATED:

    function buyOnApprove(
        IMultiToken mtkn,
        uint256 minimumReturn,
        ERC20 throughToken,
        address[] exchanges,
        bytes datas,
        uint[] datasIndexes, // including 0 and LENGTH values
        uint256[] values
    )
        public
        payable
    {
        require(datasIndexes.length == exchanges.length + 1, "buy: datasIndexes should start with 0 and end with LENGTH");
        require(values.length == exchanges.length, "buy: values should have the same length as exchanges");

        for (uint i = 0; i < exchanges.length; i++) {
            bytes memory data = new bytes(datasIndexes[i + 1] - datasIndexes[i]);
            for (uint j = datasIndexes[i]; j < datasIndexes[i + 1]; j++) {
                data[j - datasIndexes[i]] = datas[j];
            }

            if (throughToken != address(0) && values[i] == 0) {
                if (throughToken.allowance(this, exchanges[i]) == 0) {
                    throughToken.asmApprove(exchanges[i], uint256(-1));
                }
                // solium-disable-next-line security/no-low-level-calls
                require(exchanges[i].call(data), "buy: exchange arbitrary call failed");
            } else {
                // solium-disable-next-line security/no-call-value
                require(exchanges[i].call.value(values[i])(data), "buy: exchange arbitrary call failed");
            }
        }

        j = mtkn.totalSupply(); // optimization totalSupply
        uint256 bestAmount = uint256(-1);
        for (i = mtkn.tokensCount(); i > 0; i--) {
            ERC20 token = mtkn.tokens(i - 1);
            if (token.allowance(this, mtkn) == 0) {
                token.asmApprove(mtkn, uint256(-1));
            }

            uint256 amount = j.mul(token.balanceOf(this)).div(token.balanceOf(mtkn));
            if (amount < bestAmount) {
                bestAmount = amount;
            }
        }

        require(bestAmount >= minimumReturn, "buy: return value is too low");
        mtkn.bundle(msg.sender, bestAmount);
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        if (throughToken != address(0) && throughToken.balanceOf(this) > 0) {
            throughToken.asmTransfer(msg.sender, throughToken.balanceOf(this));
        }
    }
}

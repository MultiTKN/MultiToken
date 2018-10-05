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
        IMultiToken mtkn,
        uint256 amount,
        bytes callDatas,
        uint[] starts // including 0 and LENGTH values
    )
        public
    {
        sell(
            mtkn,
            amount,
            callDatas,
            starts,
            tx.origin   // solium-disable-line security/no-tx-origin
        );
    }

    function sell(
        IMultiToken mtkn,
        uint256 amount,
        bytes callDatas,
        uint[] starts, // including 0 and LENGTH values
        address to
    )
        public
    {
        mtkn.asmTransferFrom(msg.sender, this, amount);
        mtkn.unbundle(this, amount);
        change(callDatas, starts);
        to.transfer(address(this).balance);
    }

    // DEPRECATED:

    function sellOnApproveForOrigin(
        IMultiToken mtkn,
        uint256 amount,
        ERC20 throughToken,
        address[] exchanges,
        bytes datas,
        uint[] datasIndexes // including 0 and LENGTH values
    )
        public
    {
        sellOnApprove(
            mtkn,
            amount,
            throughToken,
            exchanges,
            datas,
            datasIndexes,
            tx.origin       // solium-disable-line security/no-tx-origin
        );
    }

    function sellOnApprove(
        IMultiToken mtkn,
        uint256 amount,
        ERC20 throughToken,
        address[] exchanges,
        bytes datas,
        uint[] datasIndexes, // including 0 and LENGTH values
        address to
    )
        public
    {
        if (throughToken == address(0)) {
            require(mtkn.tokensCount() == exchanges.length, "sell: mtkn should have the same tokens count as exchanges");
        } else {
            require(mtkn.tokensCount() + 1 == exchanges.length, "sell: mtkn should have tokens count + 1 equal exchanges length");
        }
        require(datasIndexes.length == exchanges.length + 1, "sell: datasIndexes should start with 0 and end with LENGTH");

        mtkn.transferFrom(msg.sender, this, amount);
        mtkn.unbundle(this, amount);

        for (uint i = 0; i < exchanges.length; i++) {
            bytes memory data = new bytes(datasIndexes[i + 1] - datasIndexes[i]);
            for (uint j = datasIndexes[i]; j < datasIndexes[i + 1]; j++) {
                data[j - datasIndexes[i]] = datas[j];
            }
            if (data.length == 0) {
                continue;
            }

            if (i == exchanges.length - 1 && throughToken != address(0)) {
                if (throughToken.allowance(this, exchanges[i]) == 0) {
                    throughToken.asmApprove(exchanges[i], uint256(-1));
                }
            } else {
                ERC20 token = mtkn.tokens(i);
                if (exchanges[i] == 0) {
                    token.asmTransfer(to, token.balanceOf(this));
                    continue;
                }
                if (token.allowance(this, exchanges[i]) == 0) {
                    token.asmApprove(exchanges[i], uint256(-1));
                }
            }
            // solium-disable-next-line security/no-low-level-calls
            require(exchanges[i].call(data), "sell: exchange arbitrary call failed");
        }

        to.transfer(address(this).balance);
        if (throughToken != address(0) && throughToken.balanceOf(this) > 0) {
            throughToken.asmTransfer(to, throughToken.balanceOf(this));
        }
    }
}

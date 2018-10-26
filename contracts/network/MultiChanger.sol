pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../interface/IMultiToken.sol";
import "../ext/CheckedERC20.sol";
import "../ext/ExternalCall.sol";


contract IEtherToken is ERC20 {
    function deposit() public payable;
    function withdraw(uint256 amount) public;
}


contract MultiChanger {
    using SafeMath for uint256;
    using CheckedERC20 for ERC20;
    using ExternalCall for address;

    function change(bytes callDatas, uint[] starts) public payable { // starts should include 0 and callDatas.length
        for (uint i = 0; i < starts.length - 1; i++) {
            require(address(this).externalCall(0, callDatas, starts[i], starts[i + 1] - starts[i]));
        }
    }

    // Ether

    function sendEthValue(address target, uint256 value) external {
        // solium-disable-next-line security/no-call-value
        require(target.call.value(value)());
    }

    function sendEthProportion(address target, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        // solium-disable-next-line security/no-call-value
        require(target.call.value(value)());
    }

    // Ether token

    function depositEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
        etherToken.deposit.value(amount)();
    }

    function depositEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
        uint256 amount = address(this).balance.mul(mul).div(div);
        etherToken.deposit.value(amount)();
    }

    function withdrawEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
        etherToken.withdraw(amount);
    }

    function withdrawEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
        uint256 amount = etherToken.balanceOf(this).mul(mul).div(div);
        etherToken.withdraw(amount);
    }

    // Token

    function transferTokenAmount(address target, ERC20 fromToken, uint256 amount) external {
        require(fromToken.asmTransfer(target, amount));
    }

    function transferTokenProportion(address target, ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        require(fromToken.asmTransfer(target, amount));
    }

    // MultiToken

    function multitokenChangeAmount(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 amount) external {
        if (fromToken.allowance(this, mtkn) == 0) {
            fromToken.asmApprove(mtkn, uint256(-1));
        }
        mtkn.change(fromToken, toToken, amount, minReturn);
    }

    function multitokenChangeProportion(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        this.multitokenChangeAmount(mtkn, fromToken, toToken, minReturn, amount);
    }
}

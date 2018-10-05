pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "../interface/IMultiToken.sol";
import "../ext/CheckedERC20.sol";


contract IEtherToken is ERC20 {
    function deposit() public payable;
    function withdraw(uint256 amount) public;
}


contract IBancorNetwork {
    function convert(
        address[] path,
        uint256 amount,
        uint256 minReturn
    )
        public
        payable
        returns(uint256);

    function claimAndConvert(
        address[] path,
        uint256 amount,
        uint256 minReturn
    )
        public
        payable
        returns(uint256);
}


contract IKyberNetworkProxy {
    function trade(
        address src,
        uint srcAmount,
        address dest,
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
    using CheckedERC20 for ERC20;

    // Source: https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function externalCall(address destination, uint value, bytes data, uint dataOffset, uint dataLength) internal returns (bool result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
                                   // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                                   // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
                destination,
                value,
                add(d, dataOffset),
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
    }

    function change(bytes callDatas, uint[] starts) public payable { // starts should include 0 and callDatas.length
        for (uint i = 0; i < starts.length - 1; i++) {
            require(externalCall(this, 0, callDatas, starts[i], starts[i + 1] - starts[i]));
        }
    }

    function sendEthValue(address target, bytes data, uint256 value) external {
        // solium-disable-next-line security/no-call-value
        require(target.call.value(value)(data));
    }

    function sendEthProportion(address target, bytes data, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        // solium-disable-next-line security/no-call-value
        require(target.call.value(value)(data));
    }

    function approveTokenAmount(address target, bytes data, ERC20 fromToken, uint256 amount) external {
        if (fromToken.allowance(this, target) != 0) {
            fromToken.asmApprove(target, 0);
        }
        fromToken.asmApprove(target, amount);
        // solium-disable-next-line security/no-low-level-calls
        require(target.call(data));
    }

    function approveTokenProportion(address target, bytes data, ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        if (fromToken.allowance(this, target) != 0) {
            fromToken.asmApprove(target, 0);
        }
        fromToken.asmApprove(target, amount);
        // solium-disable-next-line security/no-low-level-calls
        require(target.call(data));
    }

    function transferTokenAmount(address target, bytes data, ERC20 fromToken, uint256 amount) external {
        fromToken.asmTransfer(target, amount);
        if (target != address(0)) {
            // solium-disable-next-line security/no-low-level-calls
            require(target.call(data));
        }
    }

    function transferTokenProportion(address target, bytes data, ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        fromToken.asmTransfer(target, amount);
        if (target != address(0)) {
            // solium-disable-next-line security/no-low-level-calls
            require(target.call(data));
        }
    }

    // Multitoken

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

    // Ether token

    function withdrawEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
        etherToken.withdraw(amount);
    }

    function withdrawEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
        uint256 amount = etherToken.balanceOf(this).mul(mul).div(div);
        etherToken.withdraw(amount);
    }

    // Bancor Network

    function bancorSendEthValue(IBancorNetwork bancor, address[] path, uint256 value) external {
        bancor.convert.value(value)(path, value, 1);
    }

    function bancorSendEthProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        bancor.convert.value(value)(path, value, 1);
    }

    function bancorApproveTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
        if (ERC20(path[0]).allowance(this, bancor) == 0) {
            ERC20(path[0]).asmApprove(bancor, uint256(-1));
        }
        bancor.claimAndConvert(path, amount, 1);
    }

    function bancorApproveTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 amount = ERC20(path[0]).balanceOf(this).mul(mul).div(div);
        if (ERC20(path[0]).allowance(this, bancor) == 0) {
            ERC20(path[0]).asmApprove(bancor, uint256(-1));
        }
        bancor.claimAndConvert(path, amount, 1);
    }

    function bancorTransferTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
        ERC20(path[0]).asmTransfer(bancor, amount);
        bancor.convert(path, amount, 1);
    }

    function bancorTransferTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 amount = ERC20(path[0]).balanceOf(this).mul(mul).div(div);
        ERC20(path[0]).asmTransfer(bancor, amount);
        bancor.convert(path, amount, 1);
    }

    function bancorAlreadyTransferedTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
        bancor.convert(path, amount, 1);
    }

    function bancorAlreadyTransferedTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 amount = ERC20(path[0]).balanceOf(bancor).mul(mul).div(div);
        bancor.convert(path, amount, 1);
    }

    // Kyber Network

    function kyberSendEthProportion(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        kyber.trade.value(value)(
            fromToken,
            value,
            toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

    function kyberApproveTokenAmount(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 amount) external {
        if (fromToken.allowance(this, kyber) == 0) {
            fromToken.asmApprove(kyber, uint256(-1));
        }
        kyber.trade(
            fromToken,
            amount,
            toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

    function kyberApproveTokenProportion(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        this.kyberApproveTokenAmount(kyber, fromToken, toToken, amount);
    }
}

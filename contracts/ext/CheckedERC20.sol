pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


library CheckedERC20 {
    using SafeMath for uint;

    function isContract(address addr) internal view returns(bool result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            result := gt(extcodesize(addr), 0)
        }
    }

    function handleReturnBool() internal pure returns(bool result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            switch returndatasize()
            case 0 { // not a std erc20
                result := 1
            }
            case 32 { // std erc20
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            default { // anything else, should revert for safety
                revert(0, 0)
            }
        }
    }

    function handleReturnBytes32() internal pure returns(bytes32 result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            switch eq(returndatasize(), 32) // not a std erc20
            case 1 {
                returndatacopy(0, 0, 32)
                result := mload(0)
            }

            switch gt(returndatasize(), 32) // std erc20
            case 1 {
                returndatacopy(0, 64, 32)
                result := mload(0)
            }

            switch lt(returndatasize(), 32) // anything else, should revert for safety
            case 1 {
                revert(0, 0)
            }
        }
    }

    function asmTransfer(address token, address to, uint256 value) internal returns(bool) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        require(token.call(bytes4(keccak256("transfer(address,uint256)")), to, value));
        return handleReturnBool();
    }

    function asmTransferFrom(address token, address from, address to, uint256 value) internal returns(bool) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        require(token.call(bytes4(keccak256("transferFrom(address,address,uint256)")), from, to, value));
        return handleReturnBool();
    }

    function asmApprove(address token, address spender, uint256 value) internal returns(bool) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        require(token.call(bytes4(keccak256("approve(address,uint256)")), spender, value));
        return handleReturnBool();
    }

    //

    function checkedTransfer(ERC20 token, address to, uint256 value) internal {
        if (value > 0) {
            uint256 balance = token.balanceOf(this);
            require(asmTransfer(token, to, value), "asmTransfer failed");
            require(token.balanceOf(this) == balance.sub(value), "checkedTransfer: Final balance didn't match");
        }
    }

    function checkedTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        if (value > 0) {
            uint256 toBalance = token.balanceOf(to);
            require(asmTransferFrom(token, from, to, value), "asmTransferFrom failed");
            require(token.balanceOf(to) == toBalance.add(value), "checkedTransfer: Final balance didn't match");
        }
    }

    //

    function asmName(address token) internal view returns(bytes32) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        require(token.call(bytes4(keccak256("name()"))));
        return handleReturnBytes32();
    }

    function asmSymbol(address token) internal view returns(bytes32) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        require(token.call(bytes4(keccak256("symbol()"))));
        return handleReturnBytes32();
    }
}

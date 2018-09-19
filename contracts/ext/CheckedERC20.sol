pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


library CheckedERC20 {
    using SafeMath for uint;

    function isContract(address addr) internal view returns(bool result) {
        assembly {
            result := gt(extcodesize(addr), 0)
        }
    }

    function handleReturnBool() internal view returns(bool result) {
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

    function handleReturnBytes32() internal view returns(bytes32 result) {
        assembly {
            if eq(returndatasize(), 32) { // not a std erc20
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            if gt(returndatasize(), 32) { // std erc20
                returndatacopy(0, 64, 32)
                result := mload(0)
            }
            if lt(returndatasize(), 32) { // anything else, should revert for safety
                revert(0, 0)
            }
        }
    }

    function asmTransfer(address _token, address _to, uint256 _value) internal returns(bool) {
        require(isContract(_token));
        require(_token.call(bytes4(keccak256("transfer(address,uint256)")), _to, _value));
        return handleReturnBool();
    }

    function asmTransferFrom(address _token, address _from, address _to, uint256 _value) internal returns(bool) {
        require(isContract(_token));
        require(_token.call(bytes4(keccak256("transferFrom(address,address,uint256)")), _from, _to, _value));
        return handleReturnBool();
    }

    function asmApprove(address _token, address _spender, uint256 _value) internal returns(bool) {
        require(isContract(_token));
        require(_token.call(bytes4(keccak256("approve(address,uint256)")), _spender, _value));
        return handleReturnBool();
    }

    //

    function checkedTransfer(ERC20 _token, address _to, uint256 _value) internal {
        if (_value > 0) {
            uint256 balance = _token.balanceOf(this);
            asmTransfer(_token, _to, _value);
            require(_token.balanceOf(this) == balance.sub(_value), "checkedTransfer: Final balance didn't match");
        }
    }

    function checkedTransferFrom(ERC20 _token, address _from, address _to, uint256 _value) internal {
        if (_value > 0) {
            uint256 toBalance = _token.balanceOf(_to);
            asmTransferFrom(_token, _from, _to, _value);
            require(_token.balanceOf(_to) == toBalance.add(_value), "checkedTransfer: Final balance didn't match");
        }
    }

    //

    function asmName(address _token) public view returns(bytes32) {
        require(isContract(_token));
        require(_token.call(bytes4(keccak256("name()"))));
        return handleReturnBytes32();
    }

    function asmSymbol(address _token) public view returns(bytes32) {
        require(isContract(_token));
        require(_token.call(bytes4(keccak256("symbol()"))));
        return handleReturnBytes32();
    }
}

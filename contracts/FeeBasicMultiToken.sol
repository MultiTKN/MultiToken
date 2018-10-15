pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./ext/CheckedERC20.sol";
import "./BasicMultiToken.sol";


contract FeeBasicMultiToken is Ownable, BasicMultiToken {
    using CheckedERC20 for ERC20;

    uint256 constant public TOTAL_PERCRENTS = 1000000;
    uint256 internal _lendFee;

    function lendFee() public view returns(uint256) {
        return _lendFee;
    }

    function setLendFee(uint256 theLendFee) public onlyOwner {
        require(theLendFee <= 30000, "setLendFee: fee should be not greater than 3%");
        _lendFee = theLendFee;
    }

    function lend(address to, ERC20 token, uint256 amount, address target, bytes data) public payable {
        uint256 expectedBalance = token.balanceOf(this).mul(TOTAL_PERCRENTS.add(_lendFee)).div(TOTAL_PERCRENTS);
        super.lend(to, token, amount, target, data);
        require(token.balanceOf(this) >= expectedBalance, "lend: tokens must be returned with lend fee");
    }
}

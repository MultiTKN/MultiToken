pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./ext/CheckedERC20.sol";
import "./FeeBasicMultiToken.sol";
import "./MultiToken.sol";


contract FeeMultiToken is MultiToken, FeeBasicMultiToken {
    using CheckedERC20 for ERC20;

    uint256 internal _changeFee;
    uint256 internal _referralFee;

    function changeFee() public view returns(uint256) {
        return _changeFee;
    }

    function referralFee() public view returns(uint256) {
        return _referralFee;
    }

    function setChangeFee(uint256 theChangeFee) public onlyOwner {
        require(theChangeFee <= 30000, "setChangeFee: fee should be not greater than 3%");
        _changeFee = theChangeFee;
    }

    function setReferralFee(uint256 theReferralFee) public onlyOwner {
        require(theReferralFee <= 500000, "setReferralFee: fee should be not greater than 50% of changeFee");
        _referralFee = theReferralFee;
    }

    function getReturn(address fromToken, address toToken, uint256 amount) public view returns(uint256 returnAmount) {
        returnAmount = super.getReturn(fromToken, toToken, amount).mul(TOTAL_PERCRENTS.sub(_changeFee)).div(TOTAL_PERCRENTS);
    }

    function change(address fromToken, address toToken, uint256 amount, uint256 minReturn) public returns(uint256 returnAmount) {
        returnAmount = changeWithRef(fromToken, toToken, amount, minReturn, 0);
    }

    function changeWithRef(address fromToken, address toToken, uint256 amount, uint256 minReturn, address ref) public returns(uint256 returnAmount) {
        returnAmount = super.change(fromToken, toToken, amount, minReturn);
        uint256 refferalAmount = returnAmount
            .mul(_changeFee).div(TOTAL_PERCRENTS.sub(_changeFee))
            .mul(_referralFee).div(TOTAL_PERCRENTS);

        ERC20(toToken).checkedTransfer(ref, refferalAmount);
    }
}

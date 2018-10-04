pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./ext/CheckedERC20.sol";
import "./MultiToken.sol";


contract FeeMultiToken is Ownable, MultiToken {
    using CheckedERC20 for ERC20;

    uint256 constant public TOTAL_PERCRENTS = 1000000;
    uint256 internal _lendFee;
    uint256 internal _changeFee;
    uint256 internal _referralFee;

    function init(ERC20[] tokens, uint256[] weights, string name, string symbol, uint8 /*_decimals*/) public {
        super.init(tokens, weights, name, symbol, 18);
    }

    function lendFee() public view returns(uint256) {
        return _lendFee;
    }

    function changeFee() public view returns(uint256) {
        return _changeFee;
    }

    function referralFee() public view returns(uint256) {
        return _referralFee;
    }

    function setLendFee(uint256 theLendFee) public onlyOwner {
        require(theLendFee <= 30000, "setLendFee: fee should be not greater than 3%");
        _lendFee = theLendFee;
    }

    function setChangeFee(uint256 theChangeFee) public onlyOwner {
        require(theChangeFee <= 30000, "setChangeFee: fee should be not greater than 3%");
        _changeFee = theChangeFee;
    }

    function setReferralFee(uint256 theReferralFee) public onlyOwner {
        require(theReferralFee <= 500000, "setChangeFee: fee should be not greater than 50% of changeFee");
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

    function lend(address to, ERC20 token, uint256 amount, address target, bytes data) public payable {
        uint256 prevBalance = token.balanceOf(this);
        super.lend(to, token, amount, target, data);
        require(token.balanceOf(this) >= prevBalance.mul(TOTAL_PERCRENTS.add(_lendFee)).div(TOTAL_PERCRENTS), "lend: tokens must be returned with lend fee");
    }
}

pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "openzeppelin-solidity/contracts/ECRecovery.sol";


contract EOSToken is MintableToken, BurnableToken {
    function depositEther() public payable onlyOwner {
    }

    function withdrawEther(uint256 value) public onlyOwner {
        msg.sender.transfer(value);
    }
        
    function buy(
        uint256 priceMul,
        uint256 priceDiv,
        uint256 blockNumber,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) 
        public
        payable
        returns(uint256 amount)
    {
        require(checkSignature(priceMul, priceDiv, blockNumber, r, s, v), "Signature is not valid");
        amount = msg.value.mul(priceMul).div(priceDiv);
        require(this.transfer(msg.sender, amount), "There are no enough tokens available for buying");
    }

    function sell(
        uint256 amount,
        uint256 priceMul,
        uint256 priceDiv,
        uint256 blockNumber,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) 
        public
        payable
        returns(uint256 value)
    {
        require(checkSignature(priceMul, priceDiv, blockNumber, r, s, v), "Signature is not valid");
        require(this.transferFrom(msg.sender, this, amount), "There are not enough tokens available for selling");
        value = amount.mul(priceMul).div(priceDiv);
        require(msg.sender.send(value), "There are no enough ETH available for selling");
    }

    function mint(address /*_to*/, uint256 _amount) public returns(bool) {
        return super.mint(this, _amount);
    }

    function checkSignature(
        uint256 priceMul,
        uint256 priceDiv,
        uint256 blockNumber,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public view returns(bool) {
        if (block.number > blockNumber) {
            return false;
        }
        bytes32 messageHash = keccak256(abi.encodePacked(priceMul, priceDiv, blockNumber));
        bytes32 signedHash = ECRecovery.toEthSignedMessageHash(messageHash);
        return owner == ecrecover(signedHash, v < 27 ? v + 27 : v, r, s);
    }
}

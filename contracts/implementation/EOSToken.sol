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

    function mint(address /*to*/, uint256 amount) public onlyOwner returns(bool) {
        return super.mint(this, amount);
    }

    function burn(uint256 amount) public onlyOwner returns(bool) {
        return _burn(this, amount);
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
        require(block.number <= blockNumber, "Signature was outdated");
        bytes memory data = abi.encodePacked(this.buy.selector, msg.value, priceMul, priceDiv, blockNumber);
        require(checkOwnerSignature(data, r, s, v), "Signature is invalid");
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
        returns(uint256 value)
    {
        require(block.number <= blockNumber, "Signature was outdated");
        bytes memory data = abi.encodePacked(this.sell.selector, amount, priceMul, priceDiv, blockNumber);
        require(checkOwnerSignature(data, r, s, v), "Signature is invalid");
        require(this.transferFrom(msg.sender, this, amount), "There are not enough tokens available for selling");
        value = amount.mul(priceMul).div(priceDiv);
        require(msg.sender.send(value), "There are no enough ETH available for selling");
    }

    function checkOwnerSignature(
        bytes data,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public view returns(bool) {
        require(v == 0 || v == 1 || v == 27 || v == 28, "Signature v is invalid");
        bytes32 messageHash = keccak256(data);
        bytes32 signedHash = ECRecovery.toEthSignedMessageHash(messageHash);
        return owner == ecrecover(signedHash, v < 27 ? v + 27 : v, r, s);
    }
}

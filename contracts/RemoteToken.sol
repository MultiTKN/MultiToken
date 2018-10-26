pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/ECRecovery.sol";


contract RemoteToken is MintableToken, BurnableToken {
    mapping(bytes32 => bool) private _spentSignature;

    modifier isUpToDate(uint256 blockNumber) {
        require(block.number <= blockNumber, "Signature is outdated");
        _;
    }

    modifier spendSignature(bytes32 r) {
        require(!_spentSignature[r], "Signature was used");
        _spentSignature[r] = true;
        _;
    }

    constructor() public {
    }
    
    function depositEther() public payable onlyOwner {
    }

    function withdrawEther(uint256 value) public onlyOwner {
        msg.sender.transfer(value);
    }

    function mint(address /*to*/, uint256 amount) public onlyOwner returns(bool) {
        return super.mint(this, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(this, amount);
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
        spendSignature(r)
        isUpToDate(blockNumber)
        returns(uint256 amount)
    {
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
        spendSignature(r)
        isUpToDate(blockNumber)
        returns(uint256 value)
    {
        bytes memory data = abi.encodePacked(this.sell.selector, amount, priceMul, priceDiv, blockNumber);
        require(checkOwnerSignature(data, r, s, v), "Signature is invalid");
        require(this.transferFrom(msg.sender, this, amount), "There are not enough tokens available for selling");
        value = amount.mul(priceMul).div(priceDiv);
        msg.sender.transfer(value);
    }

    function checkOwnerSignature(
        bytes data,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public view returns(bool) {
        require(v == 0 || v == 1 || v == 27 || v == 28, "Signature version is invalid");
        bytes32 messageHash = keccak256(data);
        bytes32 signedHash = ECRecovery.toEthSignedMessageHash(messageHash);
        return owner == ecrecover(signedHash, v < 27 ? v + 27 : v, r, s);
    }
}

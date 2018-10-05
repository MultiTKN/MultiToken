pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";


contract EtherToken is MintableToken, BurnableToken {
    constructor() public {
        delete owner;
    }

    function() public payable {
        deposit();
    }

    function deposit() public payable {
        depositTo(msg.sender);
    }

    function depositTo(address to) public payable {
        owner = to;
        mint(to, msg.value);
        delete owner;
    }

    function withdraw(uint amount) public {
        withdrawTo(msg.sender, amount);
    }

    function withdrawTo(address to, uint amount) public {
        burn(amount);
        to.transfer(amount);
    }

    function withdrawFrom(address from, uint amount) public {
        this.transferFrom(from, this, amount);
        this.burn(amount);
        from.transfer(amount);
    }
}

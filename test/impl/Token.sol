pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";


contract Token is MintableToken, PausableToken, DetailedERC20 {
    constructor(string _symbol) public
        DetailedERC20("Token", _symbol, 18)
    {
    }
}
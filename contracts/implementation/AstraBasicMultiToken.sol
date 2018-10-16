pragma solidity ^0.4.24;

import "../FeeBasicMultiToken.sol";


contract AstraBasicMultiToken is FeeBasicMultiToken {
    constructor(ERC20[] tokens, string name, string symbol, uint8 decimals)
        public BasicMultiToken(tokens, name, symbol, decimals)
    {
    }
}

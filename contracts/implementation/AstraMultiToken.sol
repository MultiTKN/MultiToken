pragma solidity ^0.4.24;

import "../FeeMultiToken.sol";


contract AstraMultiToken is FeeMultiToken {
    constructor(ERC20[] tokens, uint256[] weights, string name, string symbol, uint8 decimals)
        public MultiToken(tokens, weights, name, symbol, decimals)
    {
    }
}
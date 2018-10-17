pragma solidity ^0.4.24;

import "../FeeBasicMultiToken.sol";


contract AstraBasicMultiToken is FeeBasicMultiToken {
    function init(ERC20[] tokens, string theName, string theSymbol, uint8 /*theDecimals*/) public {
        super.init(tokens, theName, theSymbol, 18);
    }
}

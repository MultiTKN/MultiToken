pragma solidity ^0.4.24;

import "../FeeMultiToken.sol";


contract AstraMultiToken is FeeMultiToken {
    function init(ERC20[] tokens, uint256[] tokenWeights, string theName, string theSymbol, uint8 /*theDecimals*/) public {
        super.init(tokens, tokenWeights, theName, theSymbol, 18);
    }
}

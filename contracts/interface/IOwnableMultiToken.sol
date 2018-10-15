pragma solidity ^0.4.24;


contract IOwnableMultiToken {
    // BasicMultiToken
    function disableBundling() public;
    function enableBundling() public;

    // MultiToken
    function disableChanges() public;

    // FundMultiToken
    function lockToken(address token) public;
    function setNextWeightBlockDelay(uint256 theNextWeightBlockDelay) public;
}

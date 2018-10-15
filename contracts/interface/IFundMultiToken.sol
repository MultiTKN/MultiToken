pragma solidity ^0.4.24;

import "./IMultiToken.sol";


contract IFundMultiToken is IMultiToken {
    function tokenIsLocked(address token) public view returns(bool);
    function nextWeights(address token) public view returns(uint256);
    function nextWeightStartBlock() public view returns(uint256);
    function nextWeightBlockDelay() public view returns(uint256);

    // Manager methods
    function changeWeights(uint256[] theNextWeights) public;

    // Owner methods
    function lockToken(address token) public;
    function setNextWeightBlockDelay(uint256 theNextWeightBlockDelay) public;

    bytes4 public constant InterfaceId_IFundMultiToken = 0xc123b9ad;
	  /**
	   * 0xc123b9ad ===
       *   InterfaceId_IMultiToken(0x81624e24) ^
	   *   bytes4(keccak256('tokenIsLocked(address)')) ^
       *   bytes4(keccak256('nextWeights(address)')) ^
       *   bytes4(keccak256('nextWeightStartBlock()')) ^
	   *   bytes4(keccak256('nextWeightBlockDelay()')) ^
       *   bytes4(keccak256('changeWeights(uint256[])')) ^
	   *   bytes4(keccak256('lockToken(address)')) ^
	   *   bytes4(keccak256('setNextWeightBlockDelay(uint256)'))
	   */
}

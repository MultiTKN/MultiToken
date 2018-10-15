pragma solidity ^0.4.24;

import "./IMultiToken.sol";


contract IFundMultiToken is IMultiToken {
    function tokenIsLocked(address token) public view returns(bool);
    function nextWeights(address token) public view returns(uint256);
    function nextWeightStartBlock() public view returns(uint256);
    function nextWeightBlockDelay() public view returns(uint256);

    function lockToken(address token) public;
    function changeWeights(uint256[] theNextWeights) public;

    bytes4 internal constant InterfaceId_IFundMultiToken = 0xba12e216;
	  /**
	   * 0xba12e216 ===
       *   InterfaceId_IMultiToken ^                    // === 0x9aa2e2c0
	   *   bytes4(keccak256('tokenIsLocked(address)')) ^
       *   bytes4(keccak256('nextWeights(address)')) ^
       *   bytes4(keccak256('nextWeightStartBlock()')) ^
	   *   bytes4(keccak256('nextWeightBlockDelay()')) ^
       *   bytes4(keccak256('lockToken(address)')) ^
	   *   bytes4(keccak256('changeWeights(uint256[])'))
	   */
}

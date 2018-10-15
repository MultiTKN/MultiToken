pragma solidity ^0.4.24;

import "./IBasicMultiToken.sol";


contract IMultiToken is IBasicMultiToken {
    event Update();
    event Change(address indexed _fromToken, address indexed _toToken, address indexed _changer, uint256 _amount, uint256 _return);

    function weights(address _token) public view returns(uint256);
    function changesEnabled() public view returns(bool);

    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns (uint256 returnAmount);
    function change(address _fromToken, address _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256 returnAmount);

    bytes4 internal constant InterfaceId_IMultiToken = 0x9aa2e2c0;
	  /**
	   * 0x9aa2e2c0 ===
       *   InterfaceId_IBasicMultiToken ^           // === 0x0be1304a
	   *   bytes4(keccak256('weights(address)')) ^
       *   bytes4(keccak256('changesEnabled()')) ^
       *   bytes4(keccak256('getReturn(address,address,uint256)')) ^
	   *   bytes4(keccak256('change(address,address,uint256,uint256)'))
	   */
}

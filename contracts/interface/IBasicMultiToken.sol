pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


contract IBasicMultiToken is ERC20 {
    event Bundle(address indexed who, address indexed beneficiary, uint256 value);
    event Unbundle(address indexed who, address indexed beneficiary, uint256 value);

    function tokensCount() public view returns(uint256);
    function tokens(uint i) public view returns(ERC20);
    function bundlingEnabled() public view returns(bool);
    
    function bundleFirstTokens(address _beneficiary, uint256 _amount, uint256[] _tokenAmounts) public;
    function bundle(address _beneficiary, uint256 _amount) public;

    function unbundle(address _beneficiary, uint256 _value) public;
    function unbundleSome(address _beneficiary, uint256 _value, ERC20[] _tokens) public;

    bytes4 internal constant InterfaceId_IBasicMultiToken = 0x0be1304a;
	  /**
	   * 0x0be1304a ===
	   *   bytes4(keccak256('tokensCount()')) ^
	   *   bytes4(keccak256('tokens(uint256)')) ^
       *   bytes4(keccak256('bundlingEnabled()')) ^
       *   bytes4(keccak256('bundleFirstTokens(address,uint256,uint256[])')) ^
       *   bytes4(keccak256('bundle(address,uint256)')) ^
       *   bytes4(keccak256('unbundle(address,uint256)')) ^
       *   bytes4(keccak256('unbundleSome(address,uint256,address[])'))
	   */
}

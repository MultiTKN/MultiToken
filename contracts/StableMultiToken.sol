pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./ext/CheckedERC20.sol";
import "./MultiToken.sol";


contract StableMultiToken is Ownable, MultiToken {
    using SafeMath for uint256;

    uint256 public scaleMul = 1;
    uint256 public scaleDiv = 1;

    function setScale(uint256 _scaleMul, uint256 _scaleDiv) public onlyOwner {
        scaleMul = _scaleMul;
        scaleDiv = _scaleDiv;
    }

    function totalSupply() public view returns (uint256) {
        return super.totalSupply().mul(scaleMul).div(scaleDiv);
    }
  
    function balanceOf(address _who) public view returns (uint256) {
        return super.balanceOf(_who).mul(scaleMul).div(scaleDiv);
    }
  
    function transfer(address _to, uint256 _value) public returns (bool) {
        return super.transfer(_to, _value.mul(scaleDiv).div(scaleMul));
    }
  
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return super.allowance(_owner, _spender).mul(scaleMul).div(scaleDiv);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        return super.transferFrom(_from, _to, _value.mul(scaleDiv).div(scaleMul));
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        return super.approve(_spender, _value.mul(scaleDiv).div(scaleMul));
    }
}

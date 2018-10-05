pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


contract ERC1003Caller is Ownable {
    function makeCall(address target, bytes data) external payable onlyOwner returns (bool) {
        // solium-disable-next-line security/no-call-value
        return target.call.value(msg.value)(data);
    }
}


contract ERC1003Token is ERC20 {
    ERC1003Caller private _caller = new ERC1003Caller();
    address[] internal _sendersStack;

    function caller() public view returns(ERC1003Caller) {
        return _caller;
    }

    function approveAndCall(address to, uint256 value, bytes data) public payable returns (bool) {
        _sendersStack.push(msg.sender);
        approve(to, value);
        require(_caller.makeCall.value(msg.value)(to, data));
        _sendersStack.length -= 1;
        return true;
    }

    function transferAndCall(address to, uint256 value, bytes data) public payable returns (bool) {
        transfer(to, value);
        require(_caller.makeCall.value(msg.value)(to, data));
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        address spender = (from != address(_caller)) ? from : _sendersStack[_sendersStack.length - 1];
        return super.transferFrom(spender, to, value);
    }
}

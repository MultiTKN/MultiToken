pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract AbstractDeployer is Ownable {
    function title() public view returns(string);

    function createMultiToken() internal returns(address);

    function deploy(bytes data)
        external onlyOwner returns(address result)
    {
        address mtkn = createMultiToken();
        require(mtkn.call(data), 'Bad arbitrary call');
        Ownable(mtkn).transferOwnership(msg.sender);
        return mtkn;
    }
}
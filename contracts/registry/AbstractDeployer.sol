pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract AbstractDeployer is Ownable {
    function deploy(bytes data)
        external onlyOwner returns(address result)
    {
        require(address(this).call(data), "Arbitrary call failed");
        assembly {
            returndatacopy(0, 0, 32)
            result := mload(0)
        }
    }
}
pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract AbstractDeployer is Ownable {
    string private _name;

    function name() public view returns(string) {
        return _name;
    }

    function deploy(bytes data)
        external onlyOwner returns(address result)
    {
        // solium-disable-next-line security/no-low-level-calls
        require(address(this).call(data), "Arbitrary call failed");
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            returndatacopy(0, 0, 32)
            result := mload(0)
        }
    }
}
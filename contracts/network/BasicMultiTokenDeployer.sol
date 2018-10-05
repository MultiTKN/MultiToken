pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./AbstractDeployer.sol";
import "../BasicMultiToken.sol";


contract BasicMultiTokenDeployer is AbstractDeployer {
    function name() public view returns(string) {
        return "BasicMultiTokenDeployer";
    }

    function create(ERC20[] tokens, string name, string symbol, uint8 decimals)
        external returns(address)
    {
        require(msg.sender == address(this), "Should be called only from deployer itself");
        BasicMultiToken mtkn = new BasicMultiToken(tokens, name, symbol, decimals);
        mtkn.transferOwnership(msg.sender);
        return mtkn;
    }
}

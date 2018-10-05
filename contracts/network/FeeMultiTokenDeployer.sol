pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./AbstractDeployer.sol";
import "../FeeMultiToken.sol";


contract FeeMultiTokenDeployer is AbstractDeployer {
    function title() public view returns(string) {
        return "FeeMultiTokenDeployer";
    }

    function create(ERC20[] tokens, uint256[] weights, string name, string symbol, uint8 decimals)
        external returns(address)
    {
        require(msg.sender == address(this), "Should be called only from deployer itself");
        FeeMultiToken mtkn = new FeeMultiToken(tokens, weights, name, symbol, decimals);
        mtkn.transferOwnership(msg.sender);
        return mtkn;
    }
}

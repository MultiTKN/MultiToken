pragma solidity ^0.4.24;

import "../../AbstractDeployer.sol";
import "../AstraBasicMultiToken.sol";


contract AstraBasicMultiTokenDeployer is AbstractDeployer {
    function title() public view returns(string) {
        return "AstraBasicMultiTokenDeployer";
    }

    function create(ERC20[] tokens, string name, string symbol)
        external returns(address)
    {
        require(msg.sender == address(this), "Should be called only from deployer itself");
        AstraBasicMultiToken mtkn = new AstraBasicMultiToken(tokens, name, symbol, 18);
        mtkn.transferOwnership(msg.sender);
        return mtkn;
    }
}

pragma solidity ^0.4.24;

import "../../AbstractDeployer.sol";
import "../AstraMultiToken.sol";


contract AstraFeeMultiTokenDeployer is AbstractDeployer {
    function title() public view returns(string) {
        return "AstraFeeMultiTokenDeployer";
    }

    function create(ERC20[] tokens, uint256[] weights, string name, string symbol)
        external returns(address)
    {
        require(msg.sender == address(this), "Should be called only from deployer itself");
        AstraMultiToken mtkn = new AstraMultiToken(tokens, weights, name, symbol, 18);
        mtkn.transferOwnership(msg.sender);
        return mtkn;
    }
}

pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./AbstractDeployer.sol";
import "../FeeMultiToken.sol";


contract FeeMultiTokenDeployer is AbstractDeployer {
    function create(ERC20[] theTokens, uint256[] tokenWeights, string theName, string theSymbol, uint8 theDecimals)
        external returns(address)
    {
        require(msg.sender == address(this), "Should be called only from deployer itself");
        FeeMultiToken mtkn = new FeeMultiToken(theTokens, tokenWeights, theName, theSymbol, theDecimals);
        mtkn.transferOwnership(msg.sender);
        return mtkn;
    }
}

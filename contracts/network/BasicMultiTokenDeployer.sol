pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./AbstractDeployer.sol";
import "../BasicMultiToken.sol";


contract BasicMultiTokenDeployer is Ownable, AbstractDeployer {
    function create(ERC20[] theTokens, string theName, string theSymbol, uint8 theDecimals)
        external returns(address)
    {
        require(msg.sender == address(this), "Should be called only from deployer itself");
        BasicMultiToken mtkn = new BasicMultiToken(theTokens, theName, theSymbol, theDecimals);
        mtkn.transferOwnership(msg.sender);
        return mtkn;
    }
}

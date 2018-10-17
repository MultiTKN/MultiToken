pragma solidity ^0.4.24;

import "../../AbstractDeployer.sol";
import "../AstraBasicMultiToken.sol";


contract AstraBasicMultiTokenDeployer is AbstractDeployer {
    function title() public view returns(string) {
        return "AstraBasicMultiTokenDeployer";
    }

    function createMultiToken() internal returns(address) {
        return new AstraBasicMultiToken();
    }
}

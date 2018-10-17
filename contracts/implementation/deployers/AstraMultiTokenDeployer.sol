pragma solidity ^0.4.24;

import "../../AbstractDeployer.sol";
import "../AstraMultiToken.sol";


contract AstraMultiTokenDeployer is AbstractDeployer {
    function title() public view returns(string) {
        return "AstraMultiTokenDeployer";
    }

    function createMultiToken() internal returns(address) {
        return new AstraMultiToken();
    }
}

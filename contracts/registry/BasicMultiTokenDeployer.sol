pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./IDeployer.sol";
import "../BasicMultiToken.sol";


contract BasicMultiTokenDeployer is Ownable, IDeployer {
    function deploy(bytes data) external onlyOwner returns(address) {
        // init(address[],string,string,uint8)
        require(data[0] == 0x46 && data[1] == 0x86 && data[2] == 0xb4 && data[3] == 0xbe);

        BasicMultiToken mtkn = new BasicMultiToken();
        // solium-disable-next-line security/no-low-level-calls
        require(address(mtkn).call(data));
        mtkn.transferOwnership(msg.sender);
        return mtkn;
    }
}

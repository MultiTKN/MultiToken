pragma solidity ^0.4.24;

import "../RemoteToken.sol";


contract EOSToken is RemoteToken, DetailedERC20 {
    constructor() public DetailedERC20("EOSToken", "EOST", 18) {
    }
}

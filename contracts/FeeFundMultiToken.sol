pragma solidity ^0.4.24;

import "./FundMultiToken.sol";
import "./FeeMultiToken.sol";


contract FeeFundMultiToken is FundMultiToken, FeeMultiToken {
    bool private _transfersEnabled = true;
    uint256 private _managementFee;
    bool private _managementFeeLocked;
    uint256 private _managementFeeLastPayment;

    event TransfersDisabled();
    event TransfersEnabled();
    event ManagementFeeLocked();

    constructor() public {
        _managementFeeLastPayment = now;
    }

    // Public methods

    function transfersEnabled() public view returns(bool) {
        return _transfersEnabled;
    }

    function managementFee() public view returns(uint256) {
        return _managementFee;
    }

    function managementFeeLocked() public view returns(bool) {
        return _managementFeeLocked;
    }

    function payManagementFee() public {
        uint256 period = now.sub(_managementFeeLastPayment);

        uint256 totalSupplyExcludingManagerShare = totalSupply().sub(balanceOf(manager()));
        uint256 feeShare = totalSupplyExcludingManagerShare
            .mul(_managementFee).mul(period).div(TOTAL_PERCENTS).div(365 days);
        if (feeShare > 0) {
            _mint(manager(), feeShare);
        }

        _managementFeeLastPayment = now;
    }

    // Admin methods

    function enableTransfers() public onlyManager {
        require(_transfersEnabled, "Transfers are already enabled");
        _transfersEnabled = true;
        emit TransfersEnabled();
    }

    function disableTransfers() public onlyManager {
        require(!_transfersEnabled, "Transfers are already disabled");
        _transfersEnabled = false;
        emit TransfersDisabled();
    }

    function setManagementFee(uint256 theManagementFee) public onlyManager {
        require(!_managementFeeLocked, "setManagementFee: management fee was locked");
        require(theManagementFee <= 100000, "setManagementFee: fee should be not greater than 10% per year");
        _managementFee = theManagementFee;
    }

    function lockManagementFee() public onlyManager {
        require(!_managementFeeLocked, "lockManagementFee: already locked");
        _managementFeeLocked = true;
        emit ManagementFeeLocked();
    }

    // Internal methods

    function _bundle(address beneficiary, uint256 amount, uint256[] tokenAmounts) internal {
        payManagementFee();
        super._bundle(beneficiary, amount, tokenAmounts);
    }

    function _unbundle(address beneficiary, uint256 value, ERC20[] someTokens) internal {
        payManagementFee();
        super._unbundle(beneficiary, value, someTokens);
    }
}

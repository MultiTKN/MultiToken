pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "../AbstractDeployer.sol";
import "../interface/IMultiToken.sol";


contract MultiTokenNetwork is Pausable {
    address[] private _multitokens;
    AbstractDeployer[] private _deployers;

    event NewMultitoken(address indexed mtkn);
    event NewDeployer(uint256 indexed index, address indexed oldDeployer, address indexed newDeployer);

    function multitokensCount() public view returns(uint256) {
        return _multitokens.length;
    }

    function multitokens(uint i) public view returns(address) {
        return _multitokens[i];
    }

    function allMultitokens() public view returns(address[]) {
        return _multitokens;
    }

    function deployersCount() public view returns(uint256) {
        return _deployers.length;
    }

    function deployers(uint i) public view returns(AbstractDeployer) {
        return _deployers[i];
    }

    function allWalletBalances(address wallet) public view returns(uint256[]) {
        uint256[] memory balances = new uint256[](_multitokens.length);
        for (uint i = 0; i < _multitokens.length; i++) {
            balances[i] = ERC20(_multitokens[i]).balanceOf(wallet);
        }
        return balances;
    }

    function deleteMultitoken(uint index) public onlyOwner {
        require(index < _multitokens.length, "deleteMultitoken: index out of range");
        if (index != _multitokens.length - 1) {
            _multitokens[index] = _multitokens[_multitokens.length - 1];
        }
        _multitokens.length -= 1;
    }

    function deleteDeployer(uint index) public onlyOwner {
        require(index < _deployers.length, "deleteDeployer: index out of range");
        if (index != _deployers.length - 1) {
            _deployers[index] = _deployers[_deployers.length - 1];
        }
        _deployers.length -= 1;
    }

    function disableBundlingMultitoken(uint index) public onlyOwner {
        IBasicMultiToken(_multitokens[index]).disableBundling();
    }

    function enableBundlingMultitoken(uint index) public onlyOwner {
        IBasicMultiToken(_multitokens[index]).enableBundling();
    }

    function disableChangesMultitoken(uint index) public onlyOwner {
        IMultiToken(_multitokens[index]).disableChanges();
    }

    function addDeployer(AbstractDeployer deployer) public onlyOwner whenNotPaused {
        require(deployer.owner() == address(this), "addDeployer: first set MultiTokenNetwork as owner");
        emit NewDeployer(_deployers.length, address(0), deployer);
        _deployers.push(deployer);
    }

    function setDeployer(uint256 index, AbstractDeployer deployer) public onlyOwner whenNotPaused {
        require(deployer.owner() == address(this), "setDeployer: first set MultiTokenNetwork as owner");
        emit NewDeployer(index, _deployers[index], deployer);
        _deployers[index] = deployer;
    }

    function deploy(uint256 index, bytes data) public whenNotPaused {
        address mtkn = _deployers[index].deploy(data);
        _multitokens.push(mtkn);
        emit NewMultitoken(mtkn);
    }

    function makeCall(address target, uint256 value, bytes data) public onlyOwner {
        // solium-disable-next-line security/no-call-value
        require(target.call.value(value)(data), "Arbitrary call failed");
    }
}
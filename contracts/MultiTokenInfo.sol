pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";
import "./interface/IBasicMultiToken.sol";
import "./interface/IMultiToken.sol";
import "./interface/IMultiTokenInfo.sol";
import "./ext/CheckedERC20.sol";


contract MultiTokenInfo is IMultiTokenInfo, SupportsInterfaceWithLookup {
    using CheckedERC20 for DetailedERC20;

    constructor() public {
        _registerInterface(InterfaceId_IMultiTokenInfo);
    }

    // BasicMultiToken

    function allTokens(IBasicMultiToken mtkn) public view returns(ERC20[] tokens) {
        tokens = new ERC20[](mtkn.tokensCount());
        for (uint i = 0; i < tokens.length; i++) {
            tokens[i] = mtkn.tokens(i);
        }
    }

    function allBalances(IBasicMultiToken mtkn) public view returns(uint256[] balances) {
        balances = new uint256[](mtkn.tokensCount());
        for (uint i = 0; i < balances.length; i++) {
            balances[i] = mtkn.tokens(i).balanceOf(mtkn);
        }
    }

    function allDecimals(IBasicMultiToken mtkn) public view returns(uint8[] decimals) {
        decimals = new uint8[](mtkn.tokensCount());
        for (uint i = 0; i < decimals.length; i++) {
            decimals[i] = DetailedERC20(mtkn.tokens(i)).decimals();
        }
    }

    function allNames(IBasicMultiToken mtkn) public view returns(bytes32[] names) {
        names = new bytes32[](mtkn.tokensCount());
        for (uint i = 0; i < names.length; i++) {
            names[i] = DetailedERC20(mtkn.tokens(i)).asmName();
        }
    }

    function allSymbols(IBasicMultiToken mtkn) public view returns(bytes32[] symbols) {
        symbols = new bytes32[](mtkn.tokensCount());
        for (uint i = 0; i < symbols.length; i++) {
            symbols[i] = DetailedERC20(mtkn.tokens(i)).asmSymbol();
        }
    }

    function allTokensBalancesDecimalsNamesSymbols(IBasicMultiToken mtkn) public view returns(
        ERC20[] tokens,
        uint256[] balances,
        uint8[] decimals,
        bytes32[] names,
        bytes32[] symbols
    ) {
        tokens = allTokens(mtkn);
        balances = allBalances(mtkn);
        decimals = allDecimals(mtkn);
        names = allNames(mtkn);
        symbols = allSymbols(mtkn);
    }

    // MultiToken

    function allWeights(IMultiToken mtkn) public view returns(uint256[] weights) {
        weights = new uint256[](mtkn.tokensCount());
        for (uint i = 0; i < weights.length; i++) {
            weights[i] = mtkn.weights(mtkn.tokens(i));
        }
    }

    function allTokensBalancesDecimalsNamesSymbolsWeights(IMultiToken mtkn) public view returns(
        ERC20[] tokens,
        uint256[] balances,
        uint8[] decimals,
        bytes32[] names,
        bytes32[] symbols,
        uint256[] weights
    ) {
        (tokens, balances, decimals, names, symbols) = allTokensBalancesDecimalsNamesSymbols(mtkn);
        weights = allWeights(mtkn);
    }
}

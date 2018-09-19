pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "./interface/IBasicMultiToken.sol";
import "./interface/IMultiToken.sol";
import "./interface/IMultiTokenInfo.sol";
import "./ext/CheckedERC20.sol";


contract MultiTokenInfo is IMultiTokenInfo {
    using CheckedERC20 for DetailedERC20;

    // BasicMultiToken

    function allTokens(IBasicMultiToken _mtkn) public view returns(ERC20[] _tokens) {
        _tokens = new ERC20[](_mtkn.tokensCount());
        for (uint i = 0; i < _tokens.length; i++) {
            _tokens[i] = _mtkn.tokens(i);
        }
    }

    function allBalances(IBasicMultiToken _mtkn) public view returns(uint256[] _balances) {
        _balances = new uint256[](_mtkn.tokensCount());
        for (uint i = 0; i < _balances.length; i++) {
            _balances[i] = _mtkn.tokens(i).balanceOf(_mtkn);
        }
    }

    function allDecimals(IBasicMultiToken _mtkn) public view returns(uint8[] _decimals) {
        _decimals = new uint8[](_mtkn.tokensCount());
        for (uint i = 0; i < _decimals.length; i++) {
            _decimals[i] = DetailedERC20(_mtkn.tokens(i)).decimals();
        }
    }

    function allNames(IBasicMultiToken _mtkn) public view returns(bytes32[] _names) {
        _names = new bytes32[](_mtkn.tokensCount());
        for (uint i = 0; i < _names.length; i++) {
            _names[i] = DetailedERC20(_mtkn.tokens(i)).asmName();
        }
    }

    function allSymbols(IBasicMultiToken _mtkn) public view returns(bytes32[] _symbols) {
        _symbols = new bytes32[](_mtkn.tokensCount());
        for (uint i = 0; i < _symbols.length; i++) {
            _symbols[i] = DetailedERC20(_mtkn.tokens(i)).asmSymbol();
        }
    }

    function allTokensBalancesDecimalsNamesSymbols(IBasicMultiToken _mtkn) public view returns(
        ERC20[] _tokens,
        uint256[] _balances,
        uint8[] _decimals,
        bytes32[] _names,
        bytes32[] _symbols
    ) {
        _tokens = allTokens(_mtkn);
        _balances = allBalances(_mtkn);
        _decimals = allDecimals(_mtkn);
        _names = allNames(_mtkn);
        _symbols = allSymbols(_mtkn);
    }

    // MultiToken

    function allWeights(IMultiToken _mtkn) public view returns(uint256[] _weights) {
        _weights = new uint256[](_mtkn.tokensCount());
        for (uint i = 0; i < _weights.length; i++) {
            _weights[i] = _mtkn.weights(_mtkn.tokens(i));
        }
    }

    function allTokensBalancesDecimalsNamesSymbolsWeights(IMultiToken _mtkn) public view returns(
        ERC20[] _tokens,
        uint256[] _balances,
        uint8[] _decimals,
        bytes32[] _names,
        bytes32[] _symbols,
        uint256[] _weights
    ) {
        (_tokens, _balances, _decimals, _names, _symbols) = allTokensBalancesDecimalsNamesSymbols(_mtkn);
        _weights = allWeights(_mtkn);
    }
}
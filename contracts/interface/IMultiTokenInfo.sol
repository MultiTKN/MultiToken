pragma solidity ^0.4.24;

import "./IBasicMultiToken.sol";
import "./IMultiToken.sol";


contract IMultiTokenInfo {
    function allTokens(IBasicMultiToken _mtkn) public view returns(ERC20[] _tokens);

    function allBalances(IBasicMultiToken _mtkn) public view returns(uint256[] _balances);

    function allDecimals(IBasicMultiToken _mtkn) public view returns(uint8[] _decimals);

    function allNames(IBasicMultiToken _mtkn) public view returns(bytes32[] _names);

    function allSymbols(IBasicMultiToken _mtkn) public view returns(bytes32[] _symbols);

    function allTokensBalancesDecimalsNamesSymbols(IBasicMultiToken _mtkn) public view returns(
        ERC20[] _tokens,
        uint256[] _balances,
        uint8[] _decimals,
        bytes32[] _names,
        bytes32[] _symbols
    );

    // MultiToken

    function allWeights(IMultiToken _mtkn) public view returns(uint256[] _weights);

    function allTokensBalancesDecimalsNamesSymbolsWeights(IMultiToken _mtkn) public view returns(
        ERC20[] _tokens,
        uint256[] _balances,
        uint8[] _decimals,
        bytes32[] _names,
        bytes32[] _symbols,
        uint256[] _weights
    );
}
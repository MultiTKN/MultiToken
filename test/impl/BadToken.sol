pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";


contract BadToken {
    using SafeMath for uint256;

    bytes32 public name;     // [!] bytes32 instead of string
    bytes32 public symbol;   // [!] bytes32 instead of string
    uint256 public decimals; // [!] uint256 instead of uint8

    address public owner;
    bool public paused;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier notPaused {
        require(!paused);
        _;
    }

    constructor(bytes32 _name, bytes32 _symbol, uint256 _decimals) public {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address _to, uint256 _value) public onlyOwner {
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(address(0), _to, _value);
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    // [!] Returns void instead of bool
    function transfer(address _to, uint256 _value) public notPaused {
        _transfer(msg.sender, _to, _value);
    }

    // [!] Returns void instead of bool
    function transferFrom(address _from, address _to, uint256 _value) public notPaused {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
    }

    // [!] Returns void instead of bool
    function approve(address _spender, uint256 _value) public notPaused {
        require((allowance[msg.sender][_spender] == 0) || (_value == 0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }
}
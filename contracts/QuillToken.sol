pragma solidity ^0.5.0;

import "./ERC20.sol";
contract QuillToken{
    ERC20 public token;
    address public tokenAddress;
    address public owner;

    constructor(string memory _name,string memory _symbol,uint256 _totalAmount) public{
        token = new ERC20(_name,_symbol,_totalAmount);
        tokenAddress = address(token);
        owner = msg.sender;
    }
    
    function transferFunds(address _crowdsale,uint256 _amt) public{
        require(msg.sender == owner, "Caller is not the Owner");
        token = ERC20(tokenAddress);
        token.transfer(_crowdsale,_amt);
    }   
    
}
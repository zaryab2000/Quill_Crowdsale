pragma solidity ^0.5.0;

import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";


contract SwamCrowdsale is Crowdsale{
    address public tokenAddress;
    IERC20 public SwamTtoken;
    
    constructor (
        uint256 rate,
        address payable wallet,
        IERC20 ERCtoken
        
    )
        public
        Crowdsale(rate, wallet, ERCtoken)
    {
        SwamTtoken = ERCtoken;
        tokenAddress = address(ERCtoken);
    
    }
    
    mapping(address=>uint256) public userToTokens;
    
    function get(address _user) public view returns(uint256){
        return SwamTtoken.balanceOf(_user);
    }
    
    function stake(uint256 _tokens) public{
        address user = msg.sender;
        SwamTtoken.transferFrom(user,address(this),_tokens);
        userToTokens[user] = _tokens;
    }
    

}
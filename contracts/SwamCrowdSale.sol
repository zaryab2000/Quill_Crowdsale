pragma solidity ^0.5.0;

import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";

contract SwamCrowdsale is Crowdsale{
    using SafeMath for uint256;
    
    address public tokenAddress;
    IERC20 public SwamTtoken;
    uint256 public exchangeRate = 1000; // 1 dollar = 1000 tokens
    
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
    
    function stake(uint256 _amountInDollars, uint256 _durationMonths) public{
        address user = msg.sender;
        uint256 tokens = _amountInDollars.mul(exchangeRate);
        SwamTtoken.transferFrom(user,address(this),tokens);
        // if(_amountInDollars == 2000 && _durationMonths==1){
        //     assignInterest(16,user);
        // }else if(_amountInDollars == 2000 && _durationMonths==3){
        //     assignInterest(20,user);
        // }else{
        //     handleLowInterests(user,_amountInDollars,_durationMonths);
        // }
        userToTokens[user] = tokens;
    }
    
    // function assignInterest(uint256 _interest, address _user) public{
        
    // }
    

}
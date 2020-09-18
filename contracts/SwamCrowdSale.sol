pragma solidity ^0.5.0;

import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";

contract QuillCrowdsale is Crowdsale{
    using SafeMath for uint256;
    
    uint256 public totalUIDs;
    IERC20 public QuillTtoken;
    uint256 public exchangeRate = 1000; // 1 dollar = 1000 tokens
    
    mapping (uint8 => uint8) public timeToInterest_Staked;
    mapping (uint8 => uint8) public timeToInterest_NonStaked;

    constructor (
        uint256 rate,
        address payable wallet,
        IERC20 ERCtoken
    )
        public
        Crowdsale(rate, wallet, ERCtoken)
    {
        QuillTtoken = ERCtoken;
        timeToInterest_Staked[3] = 20;
        timeToInterest_Staked[1] = 16;
        timeToInterest_NonStaked[3] = 16;
        timeToInterest_NonStaked[1] = 12;
    
    }
    
    struct userDetails{
        uint256 totalStaked;
        uint256 totalThreeMonthUIDs;
        uint256 totalOneMonthUIDs;
        address userAddress;
        bool staked;       
    }

    struct lockupDetails{
        uint256 apy;
        uint256 tokensLocked;
        uint256 lockUpTime;
        uint256 deadLineInDays;
        uint256 interestEarned;
        address uid;
        address owner;
    }
    
    mapping(address => userDetails) public userData;
    mapping(address => lockupDetails) public lockupData;
    mapping(uint256 => address) public uidList;
    mapping(address => mapping(uint256 => lockupDetails)) public threeMonthperiod;
    mapping(address => mapping(uint256 => lockupDetails)) public oneMonthperiod;
    
    
    function stake(uint256 _amountInDollars) public{
        address user = msg.sender;
        require(!userData[user].staked,"User has already STAKED");
        uint256 tokens = _amountInDollars.mul(exchangeRate);       
        // User must approve this contract first with required number to tokens to use the transferFrom function
        QuillTtoken.transferFrom(user,address(this),tokens);
        if(_amountInDollars >=2000){
            userData[user].staked = true;
            assignInterest(16,user,tokens,3);
        }
    }
    
    function lockUp(uint256 _tokens,uint8 _numberOfMonths) public{
        if(userData[msg.sender].staked){
            assignInterest(timeToInterest_Staked[_numberOfMonths],msg.sender,_tokens,_numberOfMonths);
        }else{
            assignInterest(timeToInterest_NonStaked[_numberOfMonths],msg.sender,_tokens,_numberOfMonths);
        }
    }
    
    function assignInterest(uint256 _interest, address _user,uint256 _tokens,uint256 _numberOfMonths) public{
        require(QuillTtoken.balanceOf(_user)>_tokens, "User Balance is Not Enough");
        // User must approve this contract first with required number to tokens to use the transferFrom function
        QuillTtoken.transferFrom(_user,address(this),_tokens);
        
        address uid = address(bytes20(keccak256(abi.encodePacked(msg.sender,now))));
        totalUIDs++;
        
        lockupDetails memory details = lockupDetails(_interest,_tokens,now,_numberOfMonths.mul(10),0,uid,_user);
        lockupData[uid] = details;
        userDetails memory user = userData[_user];
        user.totalStaked += _tokens;
        user.userAddress = _user;
        if(_numberOfMonths == 3){
            user.totalThreeMonthUIDs += 1;
            threeMonthperiod[_user][user.totalThreeMonthUIDs] = details;
        }else if(_numberOfMonths == 1){
            user.totalOneMonthUIDs += 1;
            oneMonthperiod[_user][user.totalOneMonthUIDs] = details;
        }
        
        userData[_user] = user;
        uidList[totalUIDs] = uid;
        
    }
    
    
    function updateInterest(address _uid) public{
        require(lockupData[_uid].owner == msg.sender, "Caller is not the OWNER");
        require(now > lockupData[_uid].lockUpTime + 7 * 1 days, "Interest can be updated only after 7 days");
        uint256 principalAmt = lockupData[_uid].tokensLocked;
        uint256 apy = lockupData[_uid].apy;
        uint256 interest = apy.mul(principalAmt).div(100);
        uint256 updatedBalance = principalAmt.add(interest);
        
        lockupDetails memory _data = lockupData[_uid];
        _data.interestEarned += interest;
        _data.tokensLocked += updatedBalance;
        _data.lockUpTime = now;
        
        lockupData[_uid] = _data;
        
        
    }
    
    function withdrawLockedTokens(address _uid) public{
        require(lockupData[_uid].owner == msg.sender, "Caller is not the OWNER");
        uint256 deadline = lockupData[_uid].deadLineInDays;
        require(now > lockupData[_uid].lockUpTime + deadline * 1 days, "LockUP period NOT OVER YET");
        uint256 withdrawAmount = lockupData[_uid].tokensLocked;
        
        if(withdrawAmount > QuillTtoken.balanceOf(address(this))){
            QuillTtoken._mint(msg.sender,withdrawAmount);
        }else{
            QuillTtoken.transfer(msg.sender,withdrawAmount);
        }   
    }
}
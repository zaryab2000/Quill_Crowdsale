 # Quill_Crowdsale

**Explained Below is the complete mechanism of how this Crowdsale Works.**

## Token Creation
**File Name**: **QuillToken.sol**
* Creates an ERC20 token once deployed.
* **transferFunds function** can be used to transfer the funds to the Crowdsale Contract.

## Crowdsale Contract
**File Name**: **QuillCrowdsale.sol**

* Implements a basic crowdsale contract on the Ethereum Blockchain.

In order to understand the factors that makes this contract one of a kind, let's dive in and understand its functionalities:
#### stake(uint256 *amountInDollars*) Function:
* Since staking is an imperative for this contract, this function allows users to stake a particular amount(*in dollars*) to the contract.

**Note:** Since I didn't use an oracle, I hardcoded the exchange rate as follows:

   ` uint256 public exchangeRate = 1000; // 1 dollar = 1000 tokens`


##### What happens Once a User Stakes ?
* Since APY that a user is supposed to receive, depends on whether the user has staked or not, I keep a record of the user's staking details.
```
struct userDetails{
        uint256 totalStaked;
        uint256 totalThreeMonthUIDs;
        uint256 totalOneMonthUIDs;
        address userAddress;
        bool staked;       
    }
```
* Moreover, the input for this function is taken in dollars. This input is then converted to token amount using the exchange rate.

#### lockUp(uint256 _tokens,uint256 _numberOfMonths) Function:
* This functions keep a record of the locked Up tokens and lockUp period.
* It simply passes this values to the ***assignInterest function***

#### assignInterest(uint256 _interest, address _user,uint256 _tokens,uint256 _numberOfMonths) Function
* This function playes a major role.
* It creates a UID(unique identity address) for any user everytime he/she locks up a certain amount of tokens.
```
        address uid = address(bytes20(keccak256(abi.encodePacked(msg.sender,now))));

```
* All necessary details about a LockUp is stored in a mapping.
```

    struct lockupDetails{
        uint256 apy;
        uint256 tokensLocked;
        uint256 lockUpTime;
        uint256 deadLineInDays;
        uint256 interestEarned;
        address uid;
        address owner;
    }
    
        mapping(address => lockupDetails) public lockupData;

```

* Moreover, tokens locked up for 3 months and 1 months are kept in separate mappings along with their owners.

```
mapping(address => mapping(uint256 => lockupDetails)) public threeMonthperiod;
 
mapping(address => mapping(uint256 => lockupDetails)) public oneMonthperiod;
```
**Note:** The first field of address in this mapping is the address of the owner who owns the lockedUp tokens.

### updateInterest(address _uid) Function
* Helps in updating the interest earned.
* The interest is updated only at the interval of 7 days.
* Updates the interest as per the assigned APY for each lockedUP amount token of(*this APY depends on factors like whether the user staked 2000 dollars initially or not, whether the lockUP period is for 1 month or 3 months*).
* This function will only be called by the owner whose UID is passed as a parameter.

### withdrawLockedTokens(address _uid) Function
* Can only be called by the owner of the function.
* Helps in withdrawing the locked up tokens but only after the lockUP period is over.
* It transfers the tokens to the respective owner in two ways:
    * If the token amount to be transferred is less the available tokens in the contract, it simply transfers the withdrawable tokens.
    * Else, it mints the token to transferred and sends it to its owner.

```
 if(withdrawAmount > QuillTtoken.balanceOf(address(this))){
            QuillTtoken._mint(msg.sender,withdrawAmount);
        }else{
            QuillTtoken.transfer(msg.sender,withdrawAmount);
        }  
```

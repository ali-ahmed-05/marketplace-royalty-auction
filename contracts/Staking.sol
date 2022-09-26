// // SPDX-License-Identifier: MIT OR Apache-2.0
// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "hardhat/console.sol";
// import "./RewardToken.sol";


// contract Staking is  Context, Ownable , ReentrancyGuard {
    
//     using SafeERC20 for IERC20;

//     address ticketConsumer;

//     RewardToken public rewardsToken;
//     IERC20 public stakingToken;

    
//     //
//     struct stakingDetail{

//         uint256 depositValue; 
//         uint256 depositBlock; 
//         uint256 withdrawBlock; 
//         uint256 pendingRewards; 
//         uint256 withDrawValue; 
//         uint256 noHasStaked; 
//         uint32 userWeight; 
//         uint256 rewardReleased; 
//         uint256 stakeTime; 
//         uint256 tickets;

//     }

//     uint256 public fee;
//     uint256 public feeRate = 20;

//     uint256 private _ether = 10**4;
//     //APY
//     uint256 private apy = 105;

//     uint256 public blocksPerYear = 10512000;
//     uint256 public blockPerday = 28800;

    
    
//     uint256 public noOfStakers;

    

//     //Tier
//     uint256 public bronze = 30000 * _ether;
//     uint256 public silver = 75000 * _ether;
//     uint256 public gold = 170000 * _ether;
//     uint256 public TotalBronze;
//     uint256 public totalSilver;
//     uint256 public totalGold;
//     uint256 public totalStakedValue;
    

//     uint32 public bronze_pool_weight = 10;
//     uint32 public silver_pool_weight = 32;
//     uint32 public gold_pool_weight = 80;

    
//     mapping(address => stakingDetail) private userStakingDetail;
    

//     //events
//     event eve_staked (uint256 amount);
//     event eve_Unstaked (uint256 amount);
//     event eve_Poolchanged (uint8 pooltype,uint256 amount);

    

//     constructor(address _token ,address _rewardToken){
        
//         stakingToken = IERC20(_token);
//         rewardsToken = RewardToken(_rewardToken);
//         _ether = 10**4;

//     }

    

//     modifier onlyConsumer() {

//         require(ticketConsumer == _msgSender(), "Ownable: caller is not the Consumer");
//         _;
//     }

//     function setBlocksPerYear(uint256 _blocksPerYear) public onlyOwner {
//         blocksPerYear = _blocksPerYear;
//     }

//     function setblockPerday(uint256 _blockPerday) public onlyOwner {
//         blockPerday = _blockPerday;
//     }

//     function setFeeRate(uint256 _feeRate) public onlyOwner{
//         require(_feeRate < 100 , "please set value under 100");
//             feeRate = _feeRate;
//     }

    

//     function setRewardToken(address _rewardToken) public onlyOwner {

//         rewardsToken = RewardToken(_rewardToken);
//     }

//     function setStakingToken(address _token) public onlyOwner {

//         stakingToken = IERC20(_token);
//     }

//     function setTicketConsumer(address _consumer) public onlyOwner {

//         ticketConsumer = _consumer;
//     }

//     function setApy (uint256 _apy) public onlyOwner {
//         require(_apy !=0 , "please provide greater than zero" );
//         apy = _apy;
//     }

//     function getAPY() public view returns(uint256) {
//         return apy;
//     }

     
     
//     function calcRewards(address account) public view returns (uint256) {
//         stakingDetail memory detail = userStakingDetail[account];
//         uint256 currentblock = block.number;
//         uint256 depositBlock = detail.depositBlock;
//         uint256 blocks = currentblock - depositBlock;
//         uint256 userShare = detail.depositValue;
//         uint256 apyRevenue = (( userShare / 100 ) * 105);
//         if(currentblock == depositBlock){
//             return 0;
//         }else if(apyRevenue < 365){

//             if(blocks < blocksPerYear){
//                 return (0);
//             }else{
//                 return ( apyRevenue * ( blocks / blocksPerYear));
//             }
            
//         }else {

//         uint256 ratePerDay = ( apyRevenue ) / 365 ;
//         return   ( blocks / blockPerday ) * ratePerDay ;
        
//         }

//     } 

    

//     function getPendingRewards()public view returns(uint256){
//         stakingDetail memory detail = userStakingDetail[_msgSender()];
//         return detail.pendingRewards;
//     }

//     function setPendingRewards(uint256 amount)private {
//         stakingDetail memory detail = userStakingDetail[_msgSender()];
//         detail.pendingRewards = amount;
//         userStakingDetail[_msgSender()] = detail;
//     }


//     function savePendingRewards() public {
//         stakingDetail memory detail = userStakingDetail[_msgSender()];
//         uint256 pending = detail.pendingRewards;
//         detail.pendingRewards = pending + calcRewards(_msgSender());
//         userStakingDetail[_msgSender()] = detail;
//     }

//     function withdrawRewards() public {
//         require(calcRewards(_msgSender()) > 0 , "no rewards to pull");
//         savePendingRewards();
//         userStakingDetail[_msgSender()].rewardReleased = userStakingDetail[_msgSender()].rewardReleased + getPendingRewards() ;
//         rewardsToken.mint(_msgSender(),getPendingRewards());
//         setPendingRewards(0);
//     }

//     //setter functions
//     function setBronzeValue(uint256 _bronze)public onlyOwner{
//         bronze = _bronze;
//     } 
//     function setSilverValue(uint256 _silver)public onlyOwner{
//         silver = _silver;
//     } 
//     function setGoldValue(uint256 _gold)public onlyOwner{
//         gold = _gold;
//     }
//     function setBronzeWeight(uint32 _weight)public onlyOwner{
//         bronze_pool_weight = _weight;
//     }
//     function setSilverWeight(uint32 _weight)public onlyOwner{
//         silver_pool_weight = _weight;
//     } 
//     function setGoldWeight(uint32 _weight)public onlyOwner{
//         gold_pool_weight = _weight;
//     }

//     //getter functions

//     function getUserWeight(address account)public view returns(uint32){
//         return userStakingDetail[account].userWeight;
//     }
    
//     function getUserStakedValue(address account)public view returns(uint256){
//         return userStakingDetail[account].depositValue;
//     } 

//     //pool weight

//     function getTicketsForUser(uint256 amount) private view returns(uint32){
//         uint32 Ticket;
//         if(amount>=bronze && amount<silver){
//             Ticket =  1;    
//         }
//         else if(amount>=silver && amount<gold){
//             Ticket =  2;
//         }
//         else if(amount>=gold){
//             Ticket =  3;
//         }
//         else{
//             Ticket =  0;
//         }
//         return Ticket;
//     }

   

//     function pool_Inc(uint256 amount) private {
//         if(amount>=bronze && amount<silver){
//             TotalBronze++;
//             emit eve_Poolchanged(0,TotalBronze);
//         }
//         else if(amount>=silver && amount<gold){
//             totalSilver++;
//             emit eve_Poolchanged(1,totalSilver);
//         }
//         else if(amount>=gold){
//             totalGold++;
//             emit eve_Poolchanged(2,totalGold);
//         }
//     }

//     function pool_Dec(uint256 amount) private {
//         if(amount>=bronze && amount<silver){
//             TotalBronze--;
//             emit eve_Poolchanged(0,TotalBronze);
//         }
//         else if(amount>=silver && amount<gold){
//             totalSilver--;
//              emit eve_Poolchanged(1,totalSilver);
//         }
//         else if(amount>=gold){
//             totalGold--;
//             emit eve_Poolchanged(2,totalGold);
//         }
//     }

//     function getPoolWeight(uint256 amount) private view returns(uint32){
//         uint32 weight;
//         if(amount>=bronze && amount<silver){
//             weight =  gold_pool_weight;
//         }
//         else if(amount>=silver && amount<gold){
//             weight = silver_pool_weight;
//         }
//         else if(amount>=gold){
//             weight = gold_pool_weight;
//         }
//         else{
//             weight = 0;
//         }
//         return weight;
//     }

  
//     function stake(uint256 amount) public nonReentrant{ 
//         require(amount >= 100,"insufficient balance for staking");
//         require(stakingToken.allowance(_msgSender(),address(this))>=amount,"Approve your token");
//         stakingDetail memory detail = userStakingDetail[_msgSender()];
//         stakingToken.safeTransferFrom(_msgSender(),address(this),amount);
//         uint256 balance = amount + detail.depositValue;
        
//         detail.userWeight = getPoolWeight(balance);
//         if(detail.noHasStaked>0){
//             pool_Dec(detail.depositValue);
//         }else{
//             detail.stakeTime = block.timestamp;
//             noOfStakers++;
//         }
//         detail.tickets = getTicketsForUser(balance);
//         pool_Inc(balance);
//         savePendingRewards();
//         detail.depositValue = balance;
//         detail.depositBlock = block.number;
//         detail.noHasStaked++;
//         detail.userWeight = getPoolWeight(balance);

//         userStakingDetail[_msgSender()] = detail;
//         totalStakedValue += amount;
//         emit eve_staked(amount);
//     }
    

//      function unStake(uint256 amount) public nonReentrant{ 
//         stakingDetail memory detail = userStakingDetail[_msgSender()];
//         uint256 balance = detail.depositValue;
//         require(amount<=balance,"insufficient balance for unstaking");
//         uint256 newBalance = 0;
//         if(block.timestamp < detail.stakeTime + 1 weeks){
           
//             uint256 withdraw_rate = 100 - feeRate ;
//             uint256 amount_80 = (amount/100) * withdraw_rate;
//             fee += amount - amount_80;

//             stakingToken.safeTransfer(_msgSender(),amount_80);
            
//         }else{
//             stakingToken.safeTransfer(_msgSender(),amount);
//         }
//         newBalance = detail.depositValue - amount;
//         detail.withDrawValue += amount;
//         savePendingRewards();
//         pool_Dec(balance);
//         if(newBalance==0){
//             detail.depositValue = 0;
//             detail.withdrawBlock = block.number;
//             detail.noHasStaked = 0;
//             detail.stakeTime = 0;
//             noOfStakers--;
//         }
//         else{ 
//             detail.depositValue = newBalance;
//             pool_Inc(newBalance);
//         }
//         detail.tickets = getTicketsForUser(newBalance);
//         detail.userWeight = getPoolWeight(newBalance);
//         userStakingDetail[_msgSender()] = detail;
//         totalStakedValue -= amount;
//         emit eve_Unstaked(amount);
//     }

//     function getUnstakedValue(address account)public view returns(uint256){
//         stakingDetail memory detail = userStakingDetail[account];
//         return detail.withDrawValue;
//     }



//     function collectFee(address account , uint256 amount)public onlyOwner{
//         require(amount <= fee , "Not enough amount to collect");
//         stakingToken.safeTransfer(account,amount);
//     }
// }
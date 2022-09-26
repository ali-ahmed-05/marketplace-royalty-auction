// SPDX-License-Identifier: MIT


pragma solidity ^0.8.4;
  

 import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol"; 
 import "@openzeppelin/contracts/utils/Context.sol"; 
 import "@openzeppelin/contracts/access/Ownable.sol"; 
 import "./interfaces/IAuction.sol"; 
  
  
 contract Auction is Context , Ownable , IAuction{ 
  
  uint256 public up; 
  bool public end; 
  
  uint256 public totalVolume; 
  uint256 public totalAuctionCompleted; 
  
 // Represents an auction on an NFT 
  struct AuctionDetails { 
  uint256 itemId; 
  // Current owner of NFT 
  address payable seller; 
  // Price (in wei) at beginning of auction 
  uint256 basePrice; 
  // Highest bidder 
  address highestBidder; 
  // Highest bid (in wei) 
  uint256 highestBid; 
  // Duration (in seconds) of auction 
  uint256 endingUnix; 
  // Time when auction started 
  uint256 startingUnix; 
  // To check if the auction has ended 
  bool ended; 
   
  } 
  
  struct Bid { 
  // Bidder's address 
  address bidder; 
  // Bidders amount 
  uint256 amount; 
  // Time 
  uint256 biddingUnix; 
   
  } 
  // Array of auctions for a token 
  mapping(uint256 => AuctionDetails) private _auctionDetail; 
  // BidsPayedPerToken 
  mapping(address => mapping(uint256 => uint256)) public payedBids; 
  // Array of bids in an auction 
  mapping(uint256 => Bid[]) private auctionBids; 
  // Array of auctions for a token 
  mapping(address => mapping(uint256 => AuctionDetails)) private tokenIdToAuction; 
  // BidsPayedPerToken 
  // mapping (address => mapping(address => mapping(uint256 => uint256))) payedBids; 
  // // Array of bids in an auction 
  // mapping( address => mapping(uint256 => Bid[])) private auctionBids; 
  // Allowed withdrawals for who didnt win the bid 
  mapping(address => uint256) private pendingReturns; 
  
  
  address payable market ;  
  constructor(){ 
   
  } 
  
  function setMarketAdress(address payable _market) public onlyOwner{ 
  market = _market; 
  } 
  
  // Events 
   
  function createAuction(uint256 itemId ,uint256 _basePrice, uint256 _endingUnix, address _msgSender) public override { 
  
  require(_auctionDetail[itemId].startingUnix <= 0,"The Auction has already started"); 
  
  //re-auction must be added 
  //AuctionDetails memory auction = tokenIdToAuction[_nftContract][_tokenId]; 
   
  _endingUnix = _endingUnix * 1 seconds; 
  _endingUnix = block.timestamp + _endingUnix; 
   
  require(_endingUnix - block.timestamp >= 9, "The ending unix should be atleast 5 minutes from now"); 
  _auctionDetail[itemId] = AuctionDetails(itemId,payable(_msgSender),_basePrice,address(0),0,_endingUnix,block.timestamp,false); 
   
   
  //emit AuctionCreated(_msgSender, _basePrice, block.timestamp, _endingUnix, referenceToken(_nftContract,_tokenId)); 
   
  } 
  
  function _updateStatus(uint256 itemId) public { //private 
  
   
  
  AuctionDetails memory auction = _auctionDetail[itemId]; 
  require(auction.ended == false,"This auction has Ended"); 
   
  if(block.timestamp > auction.endingUnix){ 
  auction.ended = true; 
   
  // _returnBids(_nftContract,_tokenId); // do it manually 
  
  } 
  
  _auctionDetail[itemId] = auction; 
  } 
  
  function canSell(uint256 _itemId) public override view returns(bool) { //private 
  
  AuctionDetails memory auction= _auctionDetail[_itemId]; 
   
  if(block.timestamp > auction.endingUnix){ 
  return true; 
  } 
  else  
  return false; 
  } 
  
  function bid(uint256 itemId) public payable { // msg.sender -> address parameter 
   
  AuctionDetails memory auction = _auctionDetail[itemId]; 
  require(auction.ended == false , "Auction has ended"); 
  require(auction.seller !=address(0),"Auction does not exist"); 
  
  end = auction.ended; 
  _updateStatus(itemId); 
  
  if(block.timestamp < auction.endingUnix){  
  
  //uint256 amount = payedBids[_msgSender()][_nftContract][_tokenId]; 
  uint256 amount = payedBids[_msgSender()][itemId]; 
  
  require (auction.highestBid < msg.value + amount && auction.basePrice<=msg.value + amount ,"Please send more funds"); 
  require (msg.sender != auction.seller, 'You cannot bid in your own auction' ); 
   
  payedBids[_msgSender()][itemId]=amount + msg.value; 
  amount = payedBids[_msgSender()][itemId]; 
   
  auction.highestBid = amount; 
  auction.highestBidder = msg.sender; 
  auctionBids[itemId].push(Bid(_msgSender(),amount,block.timestamp)); 
  
  //market.transfer(msg.value); 
  
  _auctionDetail[itemId] = auction; 
  
  totalVolume += msg.value ; 
  
  }  
  } 
  
  function getLastTime(uint256 itemId) public view returns(uint){ 
  AuctionDetails memory auction= _auctionDetail[itemId]; 
  return auction.endingUnix; 
  } 
  
  function _returnBids(uint256 itemId) private { 
   
  Bid[] memory _bid = auctionBids[itemId]; 
  AuctionDetails memory auction= _auctionDetail[itemId]; 
   
  for(uint256 i=0 ;i<=_bid.length-1 ;i++){ 
  if(_bid[i].amount != auction.highestBid ){ 
  pendingReturns[_bid[i].bidder] += payedBids[_bid[i].bidder][itemId]; 
  } 
  } 
  } 
  
  function getHighestBid(uint256 itemId)public override view returns(uint256){ 
  
  AuctionDetails memory auction = _auctionDetail[itemId]; 
  return auction.highestBid; 
  
  } 
  
  function getHighestBidder(uint256 itemId)public override view returns(address){ 
  
  AuctionDetails memory auction= _auctionDetail[itemId]; 
  return auction.highestBidder; 
  
  } 
  
  function getPendingReturns(address account)public view returns(uint256){ 
  return pendingReturns[account]; 
  } 
   
   
  
  function withdraw(uint256 itemId , address payable account) public payable { // msg.sender -> address in parameter 
  AuctionDetails memory auction = _auctionDetail[itemId]; 
  require(payedBids[account][itemId] > 0 , "No Tokens pending"); 
  require(auction.highestBidder != account , "You cant withdraw"); 
  
  uint256 amount = payedBids[account][itemId]; 
  delete payedBids[account][itemId]; 
  account.transfer(amount); 
  } 
  
  function _checkAuctionStatus(uint256 itemId) public view returns(bool){ 
   
  AuctionDetails memory auction = _auctionDetail[itemId]; 
  
  require( auction.seller != address(0) , 'Auction for this NFT is not in progress'); 
  
  return auction.ended; 
  
   
  } 
  
  function concludeAuction(uint256 itemId,address _msgSender) payable override public { 
  
  AuctionDetails memory auction = _auctionDetail[itemId]; 
  require((_msgSender == _auctionDetail[itemId].seller) || (_msgSender == _auctionDetail[itemId].highestBidder), 'You are not authorized to conclude the auction' ); 
  require(auction.endingUnix < block.timestamp,"Auction Time remaining"); 
  
  bool ended = _checkAuctionStatus(itemId); 
  
  if(!ended){ 
  _updateStatus(itemId); 
  } 
   
  delete payedBids[auction.highestBidder][itemId]; 
  uint256 payment = auction.highestBid * 1 wei; 
   
   
  // ERC721(auction.nftContract).transferFrom(address(this), auction.highestBidder , _tokenId); 
  market.transfer(payment); 
  
  totalAuctionCompleted ++; 
  
  } 
  
  
 }
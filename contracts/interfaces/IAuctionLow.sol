// SPDX-License-Identifier: MIT


pragma solidity ^0.8.4;
  
 interface IAuctionLow { 
  function createAuction(uint256 itemId ,uint256 _basePrice, uint256 _endPrice, uint256 _endingUnix, address _msgSender) external; 
  function canSell(uint256 _itemId) external view returns(bool); 
  function getLowestBidder(uint256 _itemId) external view returns(address); 
  function getLowestBid(uint256 _itemId) external view returns(uint256); 
  function concludeAuction(uint256 itemId,address _msgSender) payable external; 
 }
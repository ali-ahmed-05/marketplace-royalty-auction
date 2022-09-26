// SPDX-License-Identifier: MIT


pragma solidity ^0.8.4;
  
 interface IAuction { 
  function createAuction(uint256 itemId ,uint256 _basePrice, uint256 _endingUnix, address _msgSender) external; 
  function canSell(uint256 _itemId) external view returns(bool); 
  function getHighestBidder(uint256 _itemId) external view returns(address); 
  function getHighestBid(uint256 _itemId) external view returns(uint256); 
  function concludeAuction(uint256 itemId,address _msgSender) payable external; 
 }
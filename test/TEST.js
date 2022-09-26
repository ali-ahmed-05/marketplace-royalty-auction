const { expect } = require("chai");
const { ethers } = require("hardhat");

async function mineNBlocks(n) {
  for (let index = 0; index < n; index++) {
    await ethers.provider.send('evm_mine');
  }
}

describe("STAKING NFT TEST",  function ()  {

  
  let Snapback
  let snapback
  let SnapbackToken
  let snapbackToken
  let AuctionLow
  let auctionLow
  let Market
  let market
  
  const MAX_INT = "115792089237316195423570985008687907853269984665640564039457584007913129639935"

  let [_,per1,per2,per3] = [1,1,1,1]

  it("Should deploy all smart contracts", async function () {

    [_,per1,per2,per3] = await ethers.getSigners()
    
    SnapbackToken = await ethers.getContractFactory("SnapbackToken");
    snapbackToken = await SnapbackToken.deploy(ethers.utils.parseEther('1000000000000000000000000'));
    await snapbackToken.deployed();

    Snapback = await ethers.getContractFactory("SnapbackV1");
    snapback = await Snapback.deploy(10,"sad", snapbackToken.address);
    await snapback.deployed();

    AuctionLow = await ethers.getContractFactory("AuctionLow");
    auctionLow = await AuctionLow.deploy();
    await auctionLow.deployed();

    Market = await ethers.getContractFactory("Market");
    market = await Market.deploy(_.address,_.address);
    await market.deployed();

  });

  it("Should Create NFT", async function () {

    let create = await snapback.createToken(_.address,"dsf",50, ethers.utils.parseEther('1'));
    await create.wait()
   
   //mintToken(uint256 id , uint256 qty)
  });

  it("Should Mint NFT", async function () {

    let mint = await snapback.connect(per1).mintToken(1, 1,{value:ethers.utils.parseEther('1')})
    await mint.wait()
   
   //
  });

  // it("Should pass NFT", async function () {

  //   console.log(await snapback._getTokenPrice(0,1))
  //   console.log(await snapback.max())

  //   let mint = await snapback.connect(per1).mintToken(MAX_INT, 1,{value:ethers.utils.parseEther('0.001')})
  //   await mint.wait()
   
  //  //
  // });

  it("create Auction", async function () {

    

    let createAuction = await auctionLow.createAuction(1,10,1,10, _.address)
    await createAuction.wait()
   
   //
  });

  it("create Bid", async function () {   

    let Bid = await auctionLow.connect(per1).bid(1,0,{value:2})
    await Bid.wait()
   
   //
  });

  it("create Bid", async function () {   

    let Bid = await auctionLow.connect(per1).bid(1,0,{value:0})
    await Bid.wait()
   
   //
  });
  
  


});

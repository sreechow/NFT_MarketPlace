const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("KBMarket", function () {
  it("Should mint and trade NFTs", async function () {
    const Market = await ethers.getContractFactory('KBMarket')
    const market = await Market.deploy();
    // wait until the transaction is mined
    await market.deployed()
    const marketAddress = market.address

    const NFT = await ethers.getContractFactory('NFT')
    const nft = await NFT.deploy(marketAddress);
    // wait until the transaction is mined
    await nft.deployed()
    const nftContractAddress = nft.address

    //test listing price
    let listingPrice = await market.getListingPrice()
    listingPrice = listingPrice.toString()

    //set test value
    const auctionPrice = ethers.utils.parseUnits('100', 'ether')

    //test for minting
    await nft.mintToken('https-t1')
    await nft.mintToken('https-t2')

    await market.makeMarketItem(nftContractAddress, 1, auctionPrice, {value: listingPrice}) //value - is for msg.value in the method, this is the way to pass value in test mode
    await market.makeMarketItem(nftContractAddress, 2, auctionPrice, {value: listingPrice})

    const[_, buyerAddress] = await ethers.getSigners()

     //create market sale with adress
    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, {value:auctionPrice})

    //test for different address from different users - test accounts
    let items = await market.fetchMarketTokens()

    console.log('items', items)
    //it gives many inbuilt values, let's customize to get each field value 
    items = await Promise.all(items.map(async i => { //Promise.all - is js function
      const tokenUri = await nft.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return item;
    }))

    //test out all the items
    console.log('items', items)


  });
});

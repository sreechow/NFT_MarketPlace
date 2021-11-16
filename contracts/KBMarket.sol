//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//openzeppelin
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract KBMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;
    Counters.Counter private _tokensSold;

    address payable owner;

    //listing price per item in the marekt place
    uint256 listingPrice = 0.045 ether;

    // setup owner with contract
    constructor(){
        owner = payable(msg.sender);
    }

    //keep track of all the tokens in the marketplace
    // so the better one is struct to hold multiple data
    struct MarketToken {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner; 
        uint256 price;
        bool isSold;
    }

    // return tokenId from MarketToken
    mapping(uint256 => MarketToken) private idToMarketToken;

    //
    event MarketTokenMinted(
        uint itemId,
        address nftContract,
        uint256 tokenId,
        address payable seller,
        address payable owner,
        uint256 price,
        bool isSold
    );

    // show listing price
    function getListingPrice() public view returns(uint256) {
        return listingPrice;
    }

    // two functions to interact with contract
    // 1. Add an item to market place for sale
    // 2. Create a sale for the item 

    function makeMarketItem(
        address nftContract,
        uint tokenId,
        uint price) public payable nonReentrant{
        //nonReentract is a modifier to prevent reentry attack
        require(price > 0, 'price must be at least one wei');
        require(msg.value ==  listingPrice, 'Price must be equal to listing price');

        _tokenIds.increment();
        uint itemId = _tokenIds.current();

        //putting it up for sale - bool - no owner
        idToMarketToken[itemId] = MarketToken (
         itemId,
         nftContract,
         tokenId,
         payable(msg.sender), //seller
         payable(address(0)), // no owner, it's ethereum thing to setup as 0 
         price,
         false
        );

        //NFT transaction
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId );

        emit MarketTokenMinted(itemId, nftContract, tokenId, payable(msg.sender), payable(address(0)), price, false);

       
    }

    //function to conduct transactions and market place
    function createMarketSale(address nftContract, uint itemId) public payable nonReentrant {
        uint price = idToMarketToken[itemId].price;
        uint tokenId = idToMarketToken[itemId].tokenId;
        require(msg.value == price, 'please submit the asking price');
        //transfer amt to the seller
        idToMarketToken[itemId].seller.transfer(msg.value);

        //transfer token from contract address to buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketToken[itemId].isSold = true;
        idToMarketToken[itemId].owner = payable(msg.sender); //??
        _tokensSold.increment();

        payable(owner).transfer(listingPrice);
            
    }
    //functino to fetchmarketitems - minting, buying and selling
    //retrun the number of unsold items
    function fetchMarketTokens() public view returns(MarketToken[] memory){
        uint itemCount = _tokenIds.current();
        uint unsoldItemsCount = itemCount - _tokensSold.current();
        uint currentIndex = 0;

        //create new list with size of non-sold items from marketpalce, the size based on address(0) 
        MarketToken[] memory unsoldMarketItems = new MarketToken[](unsoldItemsCount); // define fixed size
        for(uint i=0; i< itemCount; i++){
            if(idToMarketToken[i+1].owner == address(0)){
                uint currentId = idToMarketToken[i+1].itemId;
                MarketToken storage currentItem = idToMarketToken[currentId];
                unsoldMarketItems[currentIndex] = currentItem;
                currentIndex +=1;
            }
        }

        return unsoldMarketItems;

        //loopring over no.items created
    }

    function fetchMyNFTs() public view returns(MarketToken[] memory){
        uint itemCount = _tokenIds.current();
       // uint unsoldItemsCount = itemCount - _tokensSold.current();
        uint currentIndex = 0;
        uint userItemCount = 0;

        // find user items 
        for(uint i=0; i< itemCount; i++){
            if(idToMarketToken[i+1].owner == msg.sender){
                userItemCount +=1;
            }
        }

        //create items based on user items
        MarketToken[] memory userMarketItems = new MarketToken[](userItemCount); // define fixed size
        for(uint i=0; i< itemCount; i++){
            if(idToMarketToken[i+1].owner == msg.sender){
                uint currentId = idToMarketToken[i+1].itemId;
                MarketToken storage currentItem = idToMarketToken[currentId];
                userMarketItems[currentIndex] = currentItem;
                currentIndex +=1;
            }
        }

        return userMarketItems;
    }

    //function for returing an array of minted nfts
    function fetchItemsCreated() public view returns(MarketToken[] memory){
        uint itemCount = _tokenIds.current();
        uint currentIndex = 0;
        uint userItemCount = 0;
        
        for(uint i=0; i< itemCount; i++){
            if(idToMarketToken[i+1].seller == msg.sender){
                userItemCount +=1;
            }
        }

        //create items based on  items
        MarketToken[] memory items = new MarketToken[](userItemCount); // define fixed size
        for(uint i=0; i< itemCount; i++){
            if(idToMarketToken[i+1].seller == msg.sender){
                uint currentId = idToMarketToken[i+1].itemId;
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex +=1;
            }
        }

        return items;

    }

}

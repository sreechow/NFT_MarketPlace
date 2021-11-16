//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//openzeppelin
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract NFT is ERC721URIStorage{
    using Counters for Counters.Counter;
    //counters allow us to keep track of tokenIds
    Counters.Counter private _tokenIds;

    //addres of marketplace for NFTs to interact
    address contractAddress;

    //contract address
    constructor(address marketplaceaddress) ERC721('KryptoBirdz', 'KBIRDZ'){
        contractAddress = marketplaceaddress;
    }

    function mintToken(string memory tokenURI) public returns(uint){
        _tokenIds.increment(); // from Counters contract
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        //set the token uri
        _setTokenURI(newItemId, tokenURI);
        //give the approval to transact between users
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}

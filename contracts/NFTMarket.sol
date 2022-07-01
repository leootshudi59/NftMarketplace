//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds; // every single token minted
    Counters.Counter private _itemsSold; // counts the number of NFTs sold

    address payable owner; // the owner will receive a `listingFee` contribution on every transaction on marketplace (listing, buying, selling)
    uint256 private _listingFee = 0.025 ether; // in MATIC. <=> 25000000000000000 * 10^-18 matic

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }

    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint price,
        bool sold
    );

    mapping (uint => MarketItem) private itemsList;

    constructor() {
        owner = payable(msg.sender);
    }

    function getListingPrice() public view returns (uint) {
        return _listingFee;
    }

    function createMarketItem(
        address nftContract, // "./NFT.sol" contract address
        uint tokenId,
        uint itemPrice
    ) public payable nonReentrant {
        require(itemPrice > 0, "Price must be at least 1 wei");
        require(msg.value == _listingFee, "The fee must be equal to the compulsory listing fee");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();  

        itemsList[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender), // the seller is the one who lists the item
            payable(address(0)), // no one owns the token for now
            itemPrice,
            false
        );

        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId); // sends the token from the sender's balance to the market contract balance

        emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), itemPrice, false);
    }

    function sellToken(
        address nftContract, // "./NFT.sol" contract address
        uint itemId
    ) public payable nonReentrant {
        uint price = itemsList[itemId].price;
        uint tokenId = itemsList[itemId].tokenId;
        
        require(msg.value == price, "Price is not correct");
        itemsList[itemId].seller.transfer(msg.value); // the seller receives the payment
        IERC721(nftContract).safeTransferFrom(address(this), msg.sender, tokenId); // the market balances decrements, the buyer balance increments
        itemsList[itemId].owner = payable(msg.sender); // the token ownership goes to buyer
        itemsList[itemId].sold = true; // set the value to sold
        _itemsSold.increment();
        payable(owner).transfer(_listingFee); // the market owner gets paid (on each transaction)
    }

    function fetchMarketItemsNotSold() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint index = 0;
        
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            uint currentItemId = itemsList[i + 1].itemId;
            MarketItem storage currentItem = itemsList[currentItemId];

            if (currentItem.owner == address(0)) {
                items[index] = currentItem;
                index += 1;
            }
        }

        return items;
    }

    function fetchOwnNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        address ownAddress = msg.sender;
        uint ownItemCount = 0;
        uint index = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (itemsList[i + 1].owner == ownAddress) {
                ownItemCount += 1;
            } 
        }
        
        MarketItem[] memory ownItems = new MarketItem[](ownItemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            uint currentItemId = itemsList[i + 1].itemId;
            MarketItem storage currentItem = itemsList[currentItemId];

            if (currentItem.owner == ownAddress) {
                ownItems[index] = currentItem;
                index += 1;
            }
        }
        return ownItems;
    }

    function fetchOwnCreatedNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        address ownAddress = msg.sender;
        uint ownItemCount = 0;
        uint index = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (itemsList[i + 1].seller == ownAddress) {
                ownItemCount += 1;
            } 
        }
        
        MarketItem[] memory createdItems = new MarketItem[](ownItemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            uint currentItemId = itemsList[i + 1].itemId;
            MarketItem storage currentItem = itemsList[currentItemId];

            if (currentItem.seller == ownAddress) {
                createdItems[index] = currentItem;
                index += 1;
            }
        }
        return createdItems;
    }
}
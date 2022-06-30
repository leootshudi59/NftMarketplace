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
            payable(msg.sender),
            payable(address(0)), // no one owns the token for now
            itemPrice,
            false
        );

        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId); // sends the token from the sender's balance to the market contract balance

        emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), itemPrice, false);
    }

    function marketSale() public {

    }
}
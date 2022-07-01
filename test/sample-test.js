const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarket", function() {

  let market;
  let marketContractAddress;
  let nft;
  let nftContractAddress;
  let listingPrice;
  let sellingPrice;

  beforeEach(async function() {
    const NFTMarket = await ethers.getContractFactory("NFTMarket");
    market = await NFTMarket.deploy();
    await market.deployed();
    marketContractAddress = market.address;
  
    const NFT = await ethers.getContractFactory("NFT");
    nft = await NFT.deploy(marketContractAddress);
    await nft.deployed();
    nftContractAddress = nft.address;

    listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();
    sellingPrice = ethers.utils.parseUnits('10', 'ether');
  })

  it("Should create 3 tokens", async function() {
    await nft.mintNFT("http://token1.com");
    await nft.mintNFT("http://token2.com");
    await nft.mintNFT("http://token3.com");

    await market.createMarketItem(nftContractAddress, 1, sellingPrice, {value: listingPrice});
    await market.createMarketItem(nftContractAddress, 2, sellingPrice, {value: listingPrice});
    await market.createMarketItem(nftContractAddress, 3, sellingPrice, {value: listingPrice});

    let itemsNotSold = await market.fetchMarketItemsNotSold();
    let itemsCreated = await market.fetchOwnCreatedNFTs();

    expect(itemsNotSold.length).to.equal(3);
    expect(itemsCreated.length).to.equal(3);
    for (let i = 0; i < itemsNotSold.length; i++) {
      expect(itemsNotSold[i].seller).to.equal("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
      expect(itemsNotSold[i].owner).to.equal("0x0000000000000000000000000000000000000000");
    }
    return;
  })

  it("Should execute market sales", async function() {
    await nft.mintNFT("http://token1.com");
    await nft.mintNFT("http://token2.com");
    await nft.mintNFT("http://token3.com");

    await market.createMarketItem(nftContractAddress, 1, sellingPrice, {value: listingPrice});
    await market.createMarketItem(nftContractAddress, 2, sellingPrice, {value: listingPrice});
    await market.createMarketItem(nftContractAddress, 3, sellingPrice, {value: listingPrice});
    
    const [_, buyerAddress] = await ethers.getSigners();
    await market.connect(buyerAddress).tokenSale(nftContractAddress, 1, { value: ethers.utils.parseUnits('10', 'ether') });

    let itemsBelongingToBuyer = await market.connect(buyerAddress).fetchOwnNFTs()
    let itemsNotSold = await market.fetchMarketItemsNotSold();
    // mapping on all the items
    itemsNotSold = await Promise.all(itemsNotSold.map(async i => {
      const tokenURI = await nft.tokenURI(i.tokenId);
      const item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenURI 
      }
      return item;
    }))

    expect(itemsBelongingToBuyer.length).to.equal(1);
    expect(itemsNotSold.length).to.equal(2);
    console.log('items: ', itemsNotSold);
    console.log('market address: ', marketContractAddress.toString())
    console.log('nft contract address: ', nftContractAddress.toString())
  })
});
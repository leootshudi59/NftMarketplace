//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;
    address _marketplaceAddress;

    constructor(address marketplaceAddress) ERC721("MyNFTs", "MNFT") {
        _marketplaceAddress = marketplaceAddress;
    }

    function mintNFT(string memory tokenURI) public returns (uint) {
        _tokenId.increment();
        uint256 mintedTokenId = _tokenId.current();

        _safeMint(msg.sender, mintedTokenId);
        _setTokenURI(mintedTokenId, tokenURI);
        setApprovalForAll(_marketplaceAddress, true);
        return mintedTokenId;
    }
}
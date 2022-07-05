import { ethers } from 'ethers';
import axios from 'axios';
import {useEffect, useState} from 'react';
import Web3Modal from "web3modal";
import { nftAddress, nftMarketAddress } from '../config';
import NFT from "../artifacts/contracts/NFT.sol/NFT.json";
import Market from "../artifacts/contracts/NFTMarket.sol/NFTMarket.json";
import { Head, Image } from 'next/document';


export default function Home() {
  const [nfts, setNfts] = useState([]);
  const [loaded, setLoaded] = useState('not-loaded');

  useEffect(() => {
    loadNFTs();
  }, [])

  // To be called each time the dapp is loaded
  async function loadNFTs() {
    const provider = new ethers.providers.JsonRpcProvider();
    const nftContract = new ethers.Contract(nftAddress, NFT.abi, provider);
    const marketContract = new ethers.Contract(nftMarketAddress, Market.abi, provider);
    console.log(marketContract)
    const itemsData = await marketContract.fetchMarketItemsNotSold();
    const items = await Promise.all(itemsData.map(async i => {
      const tokenUri = await nftContract.tokenURI(i.tokenId);
      const meta = await axios.get(tokenUri);
      let price = ethers.utils.formatUnits(i.price.toString(), 'ether');
      let item = {
        price,
        tokenId: i.tokenId.toNumber(),
        seller: i.seller,
        owner: i.owner,
        image: meta.data.image,
        name: meta.data.name,
        description: meta.data.description
      }
      return item;
    })) 
    setNfts(items);
    setLoaded('loaded');
  }

  if (loaded === 'loaded' && !nfts.length) {
    return (
      <div className="container">
        <h1 className="text-3xl">No items in marketplace</h1>
      </div>
    )
  }

  return (
    <div className="container mx-auto">
      <main className="flex flex-col justify-center items-center mx-auto">
        <div className="justify-center items-center max-w-8xl px-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 sm:gap-4 lg:gap-8">
            <p>test</p>
            <p>test</p>
            <p>test</p>
            <p>test</p>
          </div>
        </div>
        <h1 className="text-6xl">
          Welcome to <a href="https://nextjs.org">Next.js!</a>
        </h1>
      </main>
    </div>
  )
}
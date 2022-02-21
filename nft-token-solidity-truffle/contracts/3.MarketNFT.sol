// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

struct Listing
{
  address owner;
  bool is_active;
  uint token_id;
  uint price;
}

contract MarketNFT is ReentrancyGuard {
  using SafeMath for uint256;

  uint public listing_count = 0;
  mapping (uint => Listing) public listings;
  ERC721 nftContract = ERC721(0x1fB76D1ca7194f4C1d93785601C18e89b9f52286);
  ERC20 tokenContract = ERC20(0xCee8768384c9721c75FF42cF40d1bB2716C65d4A);

  function addListing(uint token_id, uint price) public nonReentrant
  {
    listings[listing_count] = Listing(msg.sender, true, token_id, price);
    listing_count = listing_count.add(1);
    nftContract.transferFrom(msg.sender, address(this), token_id);
  }

  function removeListing(uint listing_id) public nonReentrant
  {
    require(listings[listing_id].owner == msg.sender, "Must be owner");
    require(listings[listing_id].is_active, "Must be active");
    listings[listing_id].is_active = false;
    nftContract.transferFrom(address(this), msg.sender, listings[listing_id].token_id);
  }

  function buy(uint listing_id) public nonReentrant
  {
    require(listings[listing_id].is_active, "Must be active");
    listings[listing_id].is_active = false;
    tokenContract.transferFrom(msg.sender, listings[listing_id].owner, listings[listing_id].price);
    nftContract.transferFrom(address(this), msg.sender, listings[listing_id].token_id);
  }

  function getActiveListings(uint index) public view returns(uint)
  {
    uint j;
    for(uint i=0; i<listing_count; i++)
    {
      if(listings[i].is_active)
      {
        if(index == j)
        {
          return i;
        }
        j+=1;
      }
    }
    return 0;
  }

  function getListingsByOwner(address owner, uint index) public view returns(uint)
  {
    uint j;
    for(uint i=0; i<listing_count; i++)
    {
      if(listings[i].is_active && listings[i].owner == owner)
      {
        if(index == j)
        {
          return i;
        }
        j+=1;
      }
    }
    return 0;
  }

  function getListingsByOwnerCount(address owner) public view returns(uint)
  {
    uint result;
    for(uint i=0; i<listing_count; i++)
    {
      if(listings[i].is_active && listings[i].owner == owner)
      {
        result+=1;
      }
    }
    return result;
  }

  function getActiveListingsCount() public view returns(uint)
  {
    uint result;
    for(uint i=0; i<listing_count; i++)
    {
      if(listings[i].is_active)
      {
        result+=1;
      }
    }
    return result;
  }
}
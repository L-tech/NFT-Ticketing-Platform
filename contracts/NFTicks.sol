//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract NFTicks is ERC721URIStorage, Ownable{
    bool public saleIsActive;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 public totalTickets = 60;
    uint256 public availableTickets = 60;
    uint256 public mintPrice = 8000000000000000;
    mapping(address => uint256[]) public holderTokendIds; 
    mapping(address => bool) public checkIns;

  constructor() ERC721("Events", "ENFT") payable {
    _tokenIds.increment();
  }

  function openSale() public onlyOwner {
    saleIsActive = true;
  }


  function closeSale() public onlyOwner {
    saleIsActive = false;
  }
  function checkIn(address _address) public {
    checkIns[_address] = true;
    uint256 tokenId = holderTokendIds[_address][0];
    string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "ENFT #',
                        Strings.toString(tokenId),
                        '", "description": "A NFT-powered ticketing system for Web 3 Bridge 2022 Townhall meetting", ',
                        '"traits": [{ "trait_type": "Checked In", "value": "true" }, { "trait_type": "Purchased", "value": "true" }], ',
                        '"image": "ipfs://Qmd8FCbr5eiFcrSzj3PRovG61tVeus3HJzT3B46XXaJmWj" }'
                    )
                )
            )
        );

        string memory tokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        _setTokenURI(_tokenIds.current(), tokenURI);
  }

  function mint() public payable {
    require(availableTickets > 0, "Tickets Sold Out");
    require(msg.value >= mintPrice, "Insufficient Funds");
    require(saleIsActive, "Ticket Sales is Closed");
    string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "ENFT #',
                        Strings.toString(_tokenIds.current()),
                        '", "description": "A NFT-powered ticketing system for Web 3 Bridge 2022 Townhall meetting", ',
                        '"traits": [{ "trait_type": "Checked In", "value": "false" }, { "trait_type": "Purchased", "value": "true" }], ',
                        '"image": "ipfs://QmUuXqMvJckFhfoEaLFMEfum6roqgrjQedoRuitizw3kwQ" }'
                    )
                )
            )
        );

        string memory tokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
    console.log(tokenURI);
    _safeMint(msg.sender, _tokenIds.current());
    _setTokenURI(_tokenIds.current(), tokenURI);
    holderTokendIds[msg.sender].push(_tokenIds.current());
    _tokenIds.increment();
    availableTickets -= 1;
    
  }

  function getAvailableTickets() public view returns(uint) {
    return availableTickets;
  }


  function getTotalTickets() public view returns(uint) {
    return totalTickets;
  }

  function confirmOwnership(address _address) public view returns(bool) {
      return holderTokendIds[_address].length > 0;
  }

  // to support receiving ETH by default --
  receive() external payable {}
  fallback() external payable {}
}

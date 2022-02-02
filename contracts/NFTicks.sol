//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "./Base64.sol";
contract NFTicks is ERC721URIStorage{
    bool public saleIsActive;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public totalTickets = 10;
    uint256 public availableTickets = 10;
    mapping(address => uint256) public holderTokendIds; 

  constructor() ERC721("Events", "ENFT") payable {
    _tokenIds.increment();
  }
  function openSale() public {
    saleIsActive = true;
  }
  function closeSale() public {
    saleIsActive = false;
  }
  function mint() public {
    require(availableTickets > 0, "Tickets Sold Out");
    string[3] memory svg;
    svg[0] =  '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><text y="50">';
    svg[1] = Strings.toString(_tokenIds.current());
    svg[2] = "</text></svg>";
    string memory image = string(abi.encodePacked(svg[0], svg[1], svg[2]));
    string memory encodedImage = Base64.encode(bytes(image));
    string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "NFTix #',
                        Strings.toString(_tokenIds.current()),
                        '", "description": "A NFT-powered ticketing system", ',
                        '"traits": [{ "trait_type": "Checked In", "value": "false" }, { "trait_type": "Purchased", "value": "true" }], ',
                        '"image": '"data:image/svg+xml;base64,', encodedImage"' }'
                    )
                )
            )
        );

        string memory tokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
    console.log(encodedImage);
    _safeMint(msg.sender, _tokenIds.current());
    _setTokenURI(_tokenIds.current(), tokenURI);
    _tokenIds.increment();
    availableTickets -= 1;
    holderTokendIds[msg.sender] = 1;
  }

  function getAvailableTickets() public view returns(uint) {
    return availableTickets;
  }

  function getTotalTickets() public view returns(uint) {
    return totalTickets;
  }

  // to support receiving ETH by default
  receive() external payable {}
  fallback() external payable {}
}

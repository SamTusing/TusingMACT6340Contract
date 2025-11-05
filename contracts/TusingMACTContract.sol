// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error TusingMACT6340Contract_MaxSupplyReached();
error TusingMACT6340Contract_ValueNotEqualPrice();
error TusingMACT6340Contract_WrongAvenueForThisTransaction(); 

/// @custom:security-contact samanthatusing13@gmail.com
contract TusingMACT6340Contract is 
ERC721, 
ERC721Enumerable, 
ERC721Burnable,
ERC721Royalty,
ERC721URIStorage, 
Ownable,
ReentrancyGuard {
    
    uint256 private _tokenIdCounter;
    uint256 private immutable i_mint_price;
    uint256 private immutable i_max_tokens;
    string private s_base_uri;
    string private s_token_uri_holder; 
    address private immutable i_owner;

    event MintingCompleted(uint tokenId, address owner);
    event FundsDistributed(address owner, uint amount);
    
    
    constructor(
        uint256 _mint_price,
        uint256 _max_tokens,
        string memory _base_uri,
        address _royaltyArtist,
        uint96 _royaltyBasis
    )

        ERC721("TusingMACT6340Contract", "TMC")
        Ownable(msg.sender)
    {
        i_mint_price = _mint_price;
        i_max_tokens = _max_tokens;
        s_base_uri = _base_uri;
        _setDefaultRoyalty(_royaltyArtist, _royaltyBasis);
        i_owner = msg.sender;
    }

    receive() external payable {
        revert TusingMACT6340Contract_WrongAvenueForThisTransaction();
    }

    fallback() external payable {
        revert TusingMACT6340Contract_WrongAvenueForThisTransaction();
    }

    function safeMint(address to, uint256 tokenId, string memory uri)
        public
        onlyOwner
    {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function mintTo(
        string calldata uri
    ) public payable nonReentrant returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        if (tokenId >= i_max_tokens) {
            revert TusingMACT6340Contract_MaxSupplyReached();
        }

        if (msg.value != i_mint_price) {
            revert TusingMACT6340Contract_ValueNotEqualPrice();
        }
        _tokenIdCounter++; 
        uint256 newItemId = _tokenIdCounter;
        _safeMint(msg.sender, newItemId);
        emit MintingCompleted(newItemId, msg.sender);
        s_token_uri_holder = uri;
        payable(i_owner).transfer(address(this).balance);
        emit FundsDistributed(i_owner, msg.value);
        _setTokenURI(newItemId, uri);
        return newItemId;
    }

    function getMaxSupply() public view returns (uint256){
        return i_max_tokens;
    }

    function getMintPrice() public view returns (uint256) {
        return i_mint_price;
    }

    function getBaseURI() public view returns (string memory) {
        return s_base_uri;
    }

    function contractURI() public view returns (string memory) {
        return s_base_uri;
    }

    function setRoyalty(
        address _receiver,
        uint96 feeNumerator
    )public onlyOwner {
        _setDefaultRoyalty(_receiver, feeNumerator);
    }

    function _baseURI() internal view override returns (string memory) {
        return s_base_uri;
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
       _requireOwned(tokenId);
        return s_token_uri_holder;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage,ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

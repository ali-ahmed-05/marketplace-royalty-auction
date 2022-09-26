//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Royalties.sol";


contract SnapbackV1 is ERC1155 , Ownable , Royalties  {

    using Counters for Counters.Counter;

    // uint256 public tokenPrice; // Price of token for minter

    uint256 public tokensUserCap; // Max minting limit of specific user against specific token id

    Counters.Counter private _tokenIds; // Auto generated token IDs

    uint256 public max = type(uint256).max;

    uint256 public discount_rate = 10;

    uint256 public passRate = 0.001 ether;

    address private snapbackToken;

    mapping (uint256 => string) private _tokenURIs; // Dynamic token URIs
    mapping (uint256 => uint256) private _tokenIdCaps; // Max minting limit of specific token id

    mapping(uint256 => uint256) private _countByType; // Tokens count by token ID
    mapping(address => mapping(uint256 => uint256)) private _countByUser; // Tokens count by token id & user

    mapping(uint256 => address) public _idOwner;
    mapping(uint256 => uint256) public _tokenPrice;

    // Modifier to check if sender is owner
   

    // constructor(uint256 _tokenPrice, uint256 _tokensUserCap) ERC1155("Anything_you_want") {
    //     tokenPrice = _tokenPrice;
    //     tokensUserCap = _tokensUserCap;
    // }

    constructor(uint256 _tokensUserCap , string memory _tokenURI , address _token) ERC1155("Anything_you_want") {
        require(_tokensUserCap != 0 , "connot set zero");
        tokensUserCap = _tokensUserCap;
        _setDefaultRoyalty(_msgSender(), 250);
        createPassNFT(max,_tokenURI , passRate);
        setTokenAddress(_token);
    }

    function setTokenUserCap (uint256 _tokensUserCap) public onlyOwner{
        require(_tokensUserCap != 0 , "connot set zero");
        tokensUserCap = _tokensUserCap;
    }

    function setTokenAddress (address _token) public onlyOwner{
        require(_token != address(0) , "connot set address zero");
        snapbackToken = _token;
    }

    function increament() private {
        require( _tokenIds.current() < max -1 , "All Ids minted");
        _tokenIds.increment();
    }


    function createToken(address idOwner,string memory _tokenURI, uint256 _cap , uint256 tokenPrice) public onlyOwner returns (uint256) {
         uint256 newItemId = _tokenIds.current();
        _setTokenUri(newItemId, _tokenURI); // 5000
        increament();

        // Setting minting limit
        _setTokenCap(newItemId, _cap);
        _idOwner[newItemId] = idOwner;
        _tokenPrice[newItemId] = tokenPrice;
        return newItemId;
    }


    // Set token URI
    function _setTokenUri(uint256 tokenId, string memory tokenURI) private {
        _tokenURIs[tokenId] = tokenURI;
    }

    function _setDiscount_rate(uint256 rate) public onlyOwner {
        require(rate <= 100 , "bound 0 - 100");
        discount_rate = rate;
    }

    function _setTokenPrice(uint256 tokenId, uint256 price) public onlyOwner {
        _tokenPrice[tokenId] = price;
    }

    // Set max minting limit for token ID
    function _setTokenCap(uint256 tokenId, uint256 cap) private {
        _tokenIdCaps[tokenId] = cap;
    }

    function _getTokenPrice(uint256 tokenId, uint256 qty) public view returns(uint256) {
        uint256 price;
        if(tokenId > 0 && (balanceOf(_msgSender(), max) > 0 || IERC20(snapbackToken).balanceOf(_msgSender()) >= passRate)){
            price =  (( _tokenPrice[tokenId] * qty ) / 100 ) * (100 - discount_rate);
        }else{
            price = _tokenPrice[tokenId] * qty;
        }
        return price;
    }

    // Get minting limit for token ID
    function getTokenCap(uint256 tokenId) public view returns (uint256) {
        return _tokenIdCaps[tokenId];
    }

    // Get latest token ID
    function getLatestTokenId() public view returns (string memory) {
        uint256 currentItemId = _tokenIds.current();
        if (currentItemId == 0) {
            return "";
        }
        return Strings.toString(currentItemId - 1);
    }

    // Mint single token against token ID
    function massMintToken(uint256 qty , address receiver , string memory _tokenURI) payable onlyOwner public {
        uint256 id = createToken(owner(),_tokenURI,qty ,0);
        _mint(receiver, id, qty, "");
        _countByType[id] += qty;
    }

    function createPassNFT(uint256 qty , string memory _tokenURI , uint256 tokenPrice) private {
        uint256 id = createToken(owner(),_tokenURI,qty , tokenPrice);
        _countByType[id] += qty;
    }

    function mintToken(uint256 id , uint256 qty) payable public {
        require(
            msg.value == _getTokenPrice(id,qty),
            "Please submit asking price in order to complete the purchase"
        );
        require(
            id < _tokenIds.current(),
            "Invalid ID"
        );
        require(
            _countByType[id] + qty <= _tokenIdCaps[id],
            "No tokens left"
        );
        require(
            _countByUser[msg.sender][id] + qty <= tokensUserCap,
            "Tokens limit exceeded"
        );

        if( balanceOf(_msgSender(), max) > 0 ){
            burnToken(max);
        }else if (IERC20(snapbackToken).balanceOf(_msgSender()) >= passRate){
            IERC20(snapbackToken).transferFrom(_msgSender(),address(this),passRate);
        }

        // Pay price to owner
        payable(owner()).transfer(msg.value);

        // Mint NFT
        _mint(msg.sender, id, qty, "");

        // Increment
        _countByType[id] += qty;
        _countByUser[msg.sender][id] +=qty;
        
        _setTokenRoyalty(
        id,
        _msgSender(),
        250
        );
    }

    function burnToken(uint256 id) public {
        _burn(msg.sender, id, 1);
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        return(_tokenURIs[id]);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, Royalties) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
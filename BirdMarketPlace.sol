//SPDX-License-Identifier: UNLICENSED
pragma solidity <=0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract BirdMarketPlace is IERC721Receiver, Ownable {
    using SafeERC20 for IERC20;
    IERC721Enumerable private _nft;
    IERC20 private _token;
    uint256 private _tax = 10; // percentage

    struct ListDetail {
        address payable author;
        uint256 price;
        uint256 tokenId;
    }

    event ListNFT(address indexed from, uint256 tokenId, uint256 price);
    event UnlistNFT(address indexed from, uint256 tokenId);
    event BuyNFT(address indexed from, uint256 tokenId, uint256 price);
    event UpdateListingNFTPrice(uint256 tokenId, uint256 price);
    event SetToken(IERC20 token);
    event SetTax(uint256 tax);
    event SetNFT(IERC721Enumerable nft);

    mapping(uint256 => ListDetail) listDetail;

    constructor(
        address initialOwner,
        IERC20 token,
        IERC721Enumerable nft
    ) Ownable(initialOwner) {
        _token = token;
        _nft = nft;
    }

    function setTax(uint256 tax) public onlyOwner {
        _tax = tax;
        emit SetTax(tax);
    }

    function setToken(IERC20 token) public onlyOwner {
        _token = token;
        emit SetToken(token);
    }

    function setNft(IERC721Enumerable nft) public onlyOwner {
        nft = _nft;
        emit SetNFT(nft);
    }

    function getListedNft() public view returns (ListDetail[] memory) {
        uint256 balance = _nft.balanceOf(address(this));
        ListDetail[] memory myNft = new ListDetail[](balance);
        for (uint256 i = 0; i < balance; i++) {
            myNft[i] = listDetail[_nft.tokenOfOwnerByIndex(address(this), i)];
        }
        return myNft;
    }

    //list NFT to the market
    function listNft(uint256 tokenId, uint256 price) public {
        require(
            _nft.ownerOf(tokenId) == msg.sender,
            "You are not the owner of this NFT"
        );
        require(
            _nft.getApproved(tokenId) == address(this),
            "Market does not approved to transfer this NFT"
        );
        listDetail[tokenId] = ListDetail(payable(msg.sender), price, tokenId);
        _nft.safeTransferFrom(msg.sender, address(this), tokenId);
        emit ListNFT(msg.sender, tokenId, price);
    }

    //update NFT's price
    function updateListingNftPrice(uint256 tokenId, uint256 new_price) public {
        require(
            _nft.ownerOf(tokenId) == address(this),
            "This NFT does not exist on market place"
        );
        require(
            listDetail[tokenId].author == msg.sender,
            "Only owner can update the price of this NFT"
        );
        listDetail[tokenId].price = new_price;
        emit UpdateListingNFTPrice(tokenId, new_price);
    }

    //unlist NFT
    function unlistNft(uint256 tokenId) public {
        require(
            _nft.ownerOf(tokenId) == address(this),
            "This NFT does not exist on market place"
        );
        require(
            listDetail[tokenId].author == msg.sender,
            "Only owner can unlist this NFT"
        );
        _nft.safeTransferFrom(address(this), msg.sender, tokenId);
        emit UnlistNFT(msg.sender, tokenId);
    }

    function buyNft(uint256 tokenId, uint256 price) public {
        require(
            _token.balanceOf(msg.sender) >= price,
            "Insufficient account balance"
        );
        require(
            _nft.ownerOf(tokenId) == address(this),
            "This NFT doesn't exist on marketplace"
        );
        require(
            listDetail[tokenId].price <= price,
            "Minimum price has not been reached"
        );
        SafeERC20.safeTransferFrom(_token, msg.sender, address(this), price);
        _token.transfer(listDetail[tokenId].author, price * (100 - _tax) / 100);
          
        _nft.safeTransferFrom(address(this), msg.sender, tokenId);
        emit BuyNFT(msg.sender,tokenId, price);



    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(uint256 amount) public onlyOwner {
        require(_token.balanceOf(address(this)) >= amount, "Insufficient account balance");
        _token.transfer(msg.sender, amount);
    }

    function withdrawErc20() public onlyOwner {
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

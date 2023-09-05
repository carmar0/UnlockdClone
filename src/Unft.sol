// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract Unft is ERC721 {

    constructor() ERC721("UnftToken", "uNFT") {}

    /**
    * @dev This function is mandatory by ERC721. It is used to set NFT metadata.
    **/
    function tokenURI(uint256) public pure override returns (string memory) {
        return "";
    }

    /**
    * @dev Mints `nftTokenId` and transfers it to `to`.
    **/
    function mint(address to, uint256 nftTokenId) public {
        _mint(to, nftTokenId);
    }

    /**
    * @dev Burns `nftTokenId`.
    **/
    function burn(uint256 nftTokenId) public {
        _burn(nftTokenId);
    }

    /**
    * @dev The contract must have this function so that it can receive NFT.
     **/
     function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4){
        // 4 bytes that belong to onERC721Received(address,address,uint256,bytes)
        // selector are returned
        return IERC721Receiver.onERC721Received.selector;
    }

}
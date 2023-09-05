// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Unft.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract UnftTest is Test {
    Unft public uNFT;
    address public alice;

    function setUp() public {
        // Deploy NFT contract
        uNFT = new Unft();

        alice = makeAddr("alice");
    }

    function testMint() public {
        // Mint a NFT for Alice
        uNFT.mint(address(alice), 1);
        assertEq(IERC721(uNFT).balanceOf(address(alice)), 1);
        assertEq(IERC721(uNFT).ownerOf(1), address(alice));
    }

    function testOnERC721Received() public {
        testMint();
        // Alice sends her NFT to Unft contract
        vm.startPrank(alice);
        IERC721(uNFT).safeTransferFrom(address(alice), address(uNFT), 1);
        assertEq(IERC721(uNFT).balanceOf(address(alice)), 0);
        assertEq(IERC721(uNFT).balanceOf(address(uNFT)), 1);
        assertEq(IERC721(uNFT).ownerOf(1), address(uNFT));
    }

    function testBurn() public {
        testMint();
        vm.startPrank(alice);
        uNFT.burn(1);
        assertEq(IERC721(uNFT).balanceOf(address(alice)), 0);
        assertEq(IERC721(uNFT).balanceOf(address(uNFT)), 0);
    }
}
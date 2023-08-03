// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Utoken.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

contract UtokenTest is Test {

    Utoken public uToken;
    address public alice;
    address public bob;

    function setUp() public {
        uToken = new Utoken();   
    }

    function testMint() public {  
        alice = makeAddr("alice");
        uToken.mint(alice, 1 ether);
        assertEq(IERC20(address(uToken)).balanceOf(alice), 1 ether);
    }

    function testBurn() public {
        bob = makeAddr("bob");
        uToken.mint(bob, 1 ether);
        assertEq(IERC20(address(uToken)).balanceOf(bob), 1 ether);
        uToken.burn(bob, 1 ether);
        assertEq(IERC20(address(uToken)).balanceOf(bob), 0);
    }

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Utoken.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract UtokenTest is Test {
    Utoken public uToken;
    address public alice;

    function setUp() public {
        uToken = new Utoken();
        alice = makeAddr("alice");
    }

    function testMint() public {
        // Alice tries to mint 0 Utokens
        vm.expectRevert("Invalid mint amount");
        uToken.mint(alice, 0);

        // Alice mints 1 Utoken
        uToken.mint(alice, 1 ether);
        assertEq(IERC20(address(uToken)).balanceOf(alice), 1 ether);
    }

    function testBurn() public {
        testMint();
        // Alice tries tu burn 0 Utokens
        vm.expectRevert("Invalid burn amount");
        uToken.burn(alice, 0);

        // Alice burns 1 Utoken
        uToken.burn(alice, 1 ether);
        assertEq(IERC20(address(uToken)).balanceOf(alice), 0);
    }
}

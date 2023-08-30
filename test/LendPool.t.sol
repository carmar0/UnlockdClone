// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LendPool.sol";
import "../src/Utoken.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LendPoolTest is Test {
    // load to next string the url that is saved in the file ".env"
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    // variables
    LendPool public lendpool;
    Utoken public utoken;
    address public alice;
    // WBTC contract address deployed on Mainnet
    address public wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    function setUp() public {
        // Mainnet fork is created and selected to be used from next line
        vm.createSelectFork(MAINNET_RPC_URL);
        // contracts deployment
        utoken = new Utoken();
        lendpool = new LendPool(address(utoken));

        alice = makeAddr("alice");
         
        // deal 50 WBTC to LendPool.sol (WBTC has 8 decimals)
        deal(wbtc, address(lendpool), 50 * 1e8);
        assertEq(IERC20(wbtc).balanceOf(address(lendpool)), 50 * 1e8);
    }

    function testDeposit() public {
        // deal 2 WBTC to alice 
        deal(wbtc, address(alice), 2 * 1e8);
        assertEq(IERC20(wbtc).balanceOf(address(alice)), 2 * 1e8);

        vm.startPrank(alice);
        // alice makes a deposit of 2 WBTC. First she must approve the
        // LendPool contract to move her funds
        IERC20(wbtc).approve(address(lendpool), 2 * 1e8);
        lendpool.deposit(wbtc, 2 * 1e8, address(alice));
        assertEq(IERC20(wbtc).balanceOf(address(alice)), 0);
        assertEq(IERC20(wbtc).balanceOf(address(utoken)), 2 * 1e8);
        // alice receives 2 Utokens
        assertEq(IERC20(address(utoken)).balanceOf(address(alice)), 2 * 1e8);
    }

    
    function testWithdraw() public {
        // alice deposits 2 WBTC
        testDeposit();
        uint256 deposit = block.timestamp;
        // 6 months = 15552000 seconds
        uint256 withdraw = deposit + 15552000;
        // set the block.timestamp 6 months later
        vm.warp(withdraw); 
 
        vm.stopPrank();
        vm.prank(address(utoken));
        // Utoken.sol approves LendPool.sol to move 2 WBTC
        IERC20(wbtc).approve(address(lendpool), 2 * 1e8);
                      
        // alice withdraws her 2 WBTC
        vm.startPrank(alice);
        lendpool.withdraw(wbtc, 2 * 1e8, address(alice));
        // Now alice has more than 2 WBTC (include rewards)
        assertGt(IERC20(wbtc).balanceOf(address(alice)), 2 * 1e8);
        assertEq(IERC20(address(utoken)).balanceOf(address(alice)), 0);
    }
    
}
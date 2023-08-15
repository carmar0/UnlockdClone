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

        lendpool = new LendPool();
        utoken = new Utoken();
        alice = makeAddr("alice");
    }

    function testDeposit() public {
        // give 10 WBTC to alice (WBTC has 8 decimals)
        deal(wbtc, address(alice), 10 * 1e8);
        assertEq(IERC20(wbtc).balanceOf(address(alice)), 10 * 1e8);

        vm.startPrank(alice);
        // alice makes a deposit of 2 WBTC at LendPool.sol
        IERC20(wbtc).approve(address(lendpool), 2 * 1e8);
        lendpool.deposit(wbtc, 2 * 1e8, address(alice));
        assertEq(IERC20(wbtc).balanceOf(address(alice)), 8 * 1e8);
        assertEq(IERC20(wbtc).balanceOf(address(lendpool)), 2 * 1e8);
    }
}

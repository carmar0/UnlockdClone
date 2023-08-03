// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LendPool.sol";

contract LendPoolTest is Test {

    LendPool public lendpool;

    function setUp() public {
        lendpool = new LendPool();
        
    }


}

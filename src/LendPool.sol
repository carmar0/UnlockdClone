// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LendPool {
    error NullAmount();
    error InvalidAddress();

    function deposit(address asset, uint256 amount, address onBehalfOf) public {
        if (amount == 0) revert NullAmount();
        if (onBehalfOf == address(0)) revert InvalidAddress();

        // Transfer the asset to LendPool.sol
        IERC20(asset).transferFrom(msg.sender, address(this), amount);

        // Mint uTokens to onBehalfOf address
    }
}

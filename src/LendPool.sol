// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IUtoken {
    function mint(address to, uint256 amount) external; 
}

contract LendPool {
    error NullAmount();
    error InvalidAddress();

    address public immutable utoken;

    constructor(address _utoken) {
        utoken = _utoken;
    }

    function deposit(address asset, uint256 amount, address onBehalfOf) public {
        if (amount == 0) revert NullAmount();
        if (onBehalfOf == address(0)) revert InvalidAddress();

        // Transfer the asset to Utoken.sol
        IERC20(asset).transferFrom(msg.sender, utoken, amount);

        // Mint uTokens to onBehalfOf address
        IUtoken(utoken).mint(onBehalfOf, amount);
    }
}
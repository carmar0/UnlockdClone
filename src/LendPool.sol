// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LendPool {

    error NullAmount();

    address uToken;

    function deposit(address asset, uint256 amount, address onBehalfOf) public {

        if(amount == 0) revert NullAmount();

        IERC20(asset).approve(address(this), amount);
        IERC20(asset).transferFrom(msg.sender, uToken, amount);





    }

}

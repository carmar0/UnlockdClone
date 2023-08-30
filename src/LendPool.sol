// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IUtoken {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external; 
}

contract LendPool {
    error NullAmount();
    error InvalidAddress();

    address public immutable uToken;

    uint256 public depositedTime;
    uint256 public interest;
    uint256 public amountGenerated;
    uint256 public amountToWithdraw;

    struct Deposit {
        uint256 amount;
        uint256 depositedAt;
        uint256 withdrawedAt;
    }

    mapping(address => mapping(address => Deposit)) public deposits;

    constructor(address _utoken) {
        uToken = _utoken;
    }

    function deposit(address asset, uint256 amount, address onBehalfOf) public {
        if (amount == 0) revert NullAmount();
        if (onBehalfOf == address(0)) revert InvalidAddress();

        Deposit storage deposit = deposits[msg.sender][asset];
        deposit.depositedAt = block.timestamp;

        // Transfer the asset to Utoken.sol
        IERC20(asset).transferFrom(msg.sender, uToken, amount);

        // Mint uTokens to onBehalfOf address
        IUtoken(uToken).mint(onBehalfOf, amount);
    }

    function withdraw(address asset, uint256 amount, address to) public {
        if (amount == 0) revert NullAmount();
        if (to == address(0)) revert InvalidAddress();

        Deposit storage deposit = deposits[msg.sender][asset];
        deposit.withdrawedAt = block.timestamp;

        // Time in seconds the asset has been deposited
        depositedTime = deposit.withdrawedAt - deposit.depositedAt;
        // Interest generated (interest rate = 5% anual)
        interest = (((time * 5) * 1e18) / 365 days) / 100;
        amountGenerated = (amount * interest) / 1e18;

        amountToWithdraw = amount + amountGenerated;

        IERC20(asset).transferFrom(uToken, address(this), amount);
        IERC20(asset).transfer(to, amountToWithdraw);
        IUtoken(uToken).burn(msg.sender, amount);
    }



}
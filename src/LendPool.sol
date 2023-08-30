// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IUtoken {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external; 
}

contract LendPool {

    event Deposited();
    event Withdrawed();

    error NullAmount();
    error InvalidAddress();
    error NotEnoughBalance();

    address public immutable uToken;

    struct DepositData {
        uint256 balance;
        uint256 lastDeposit;
    }

    mapping(address => mapping(address => DepositData)) public deposits;

    constructor(address _utoken) {
        uToken = _utoken;
    }

    function deposit(address asset, uint256 amount, address onBehalfOf) public {
        if (amount == 0) revert NullAmount();
        if (onBehalfOf == address(0)) revert InvalidAddress();

        // Update the user's deposit data
        DepositData storage assetDeposit = deposits[msg.sender][asset];
        assetDeposit.balance += amount;
        assetDeposit.lastDeposit = block.timestamp;

        // Transfer the asset to Utoken.sol
        IERC20(asset).transferFrom(msg.sender, uToken, amount);

        // Mint uTokens to onBehalfOf address
        IUtoken(uToken).mint(onBehalfOf, amount);

        emit Deposited();
    }

    function withdraw(address asset, uint256 amount, address to) public {
        if (amount == 0) revert NullAmount();
        if (to == address(0)) revert InvalidAddress();

        DepositData storage assetDeposit = deposits[msg.sender][asset];

        if(amount > assetDeposit.balance) revert NotEnoughBalance();

        // Transfer the asset and rewards to "to" address and burn uTokens
        IERC20(asset).transferFrom(uToken, address(this), amount);
        IERC20(asset).transfer(to, amount + calculateRewards(msg.sender, asset, amount));
        IUtoken(uToken).burn(msg.sender, amount);

        // Update the user's deposit data
        assetDeposit.balance -= amount;
        assetDeposit.lastDeposit = block.timestamp;

        emit Withdrawed();
    }

    function calculateRewards(address supplier, address asset, uint256 amount) internal view returns(uint256) {
        // Time in seconds the asset has been deposited
        uint256 time = block.timestamp - deposits[supplier][asset].lastDeposit;
        // Interest (5 % annual)
        uint256 interest = (((time * 5) * 1e18) / 365 days) / 100;

        uint256 rewards = (amount * interest) / 1e18;
        return rewards;
    }
    
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IUtoken {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external; 
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns(address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract LendPool {

    event Deposited();
    event Withdrawed();

    error NullAmount();
    error InvalidAddress();
    error NotEnoughBalance();
    error NotNftOwner();
    error onlyOneLoan();

    address public immutable uToken;

    struct DepositData {
        uint256 balance;
        uint256 lastDeposit;
    }

    struct Loan {
        uint256 amount;
        uint256 nftTokenId;
        bool active; // true when it is not repaid 
    }

    mapping(address => mapping(address => DepositData)) deposits;
    mapping(address => Loan) loans;

    modifier onlyNftOwner(address nftAddress, uint256 tokenId) {
        if (IERC721(nftAddress).ownerOf(tokenId) != msg.sender) {
            revert NotNftOwner();
        }
        _;
    }

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
    
    function borrow(
        address asset,
        uint256 amount,
        address nftAsset,
        uint256 nftTokenId,
        address onBehalfOf) public onlyNftOwner(nftAsset, nftTokenId) {

        Loan storage loan = loans[msg.sender];

        // only 1 loan per user
        if (loan.active) revert onlyOneLoan();

        // query Nft price on Chainlink


    }

    function getNftPrice(address nftAddress, uint256 nftTokenId)
        public returns(uint256) {
       
        ( , int256 answer, , , ) = AggregatorV3Interface(nftAddress).latestRoundData();
        return uint256(answer);
    }


               

        
}
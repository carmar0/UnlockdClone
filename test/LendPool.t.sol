// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LendPool.sol";
import "../src/Utoken.sol";
import "../src/Unft.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract LendPoolTest is Test {
    // load to next string the url that is saved in the file ".env"
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    // variables
    LendPool public lendpool;
    Utoken public utoken;
    Unft public uNFT;
    address public alice;

    // WBTC contract address deployed on Mainnet
    address public wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    // LINK (ChainLink Token) contract address deployed on Mainnet
    address public link = 0x514910771AF9Ca656af840dff83E8264EcF986CA;

    // NFT collection address deployed on Mainnet: Bored Ape Yacht Club,
    // Azuki and BEANZ Official
    address baycNFT = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    address azukiNFT = 0xED5AF388653567Af2F388E6224dC7C4b3241C544;
    address beanzNFT = 0x306b1ea3ecdf94aB739F1910bbda052Ed4A9f949;

    // Chainlink's aggregator contract addresses for the next NFT floor
    // prices on Mainnet: Bored Ape Yacht Club, Azuki and BEANZ Official
    address baycAgg = 0x352f2Bc3039429fC2fe62004a1575aE74001CfcE;
    address azukiAgg = 0xA8B9A447C73191744D5B79BcE864F343455E1150;
    address beanzAgg = 0xA97477aB5ab6ED2f6A2B5Cbe59D71e88ad334b90;

    function setUp() public {
        // Mainnet fork is created and selected to be used from next line
        vm.createSelectFork(MAINNET_RPC_URL);

        // contracts deployment
        utoken = new Utoken();
        uNFT = new Unft();
        lendpool = new LendPool(address(utoken), address(uNFT));

        alice = makeAddr("alice");

        // deal 1000 WBTC to LendPool.sol (WBTC has 8 decimals)
        deal(wbtc, address(lendpool), 1000 * 1e8);
        assertEq(IERC20(wbtc).balanceOf(address(lendpool)), 1000 * 1e8);
        // deal 1000 LINK to LendPool.sol (LINK has 18 decimals)
        deal(link, address(lendpool), 1000 * 1e18);
        assertEq(IERC20(link).balanceOf(address(lendpool)), 1000 * 1e18);
    }

    function testDeposit() public {
        // deal 2 WBTC to alice
        deal(wbtc, address(alice), 2 * 1e8);
        assertEq(IERC20(wbtc).balanceOf(address(alice)), 2 * 1e8);

        // Alice wants to deposit WBTC. First she must approve the
        // LendPool contract to move her funds
        vm.startPrank(alice);
        IERC20(wbtc).approve(address(lendpool), 2 * 1e8);

        // Alice tries to deposit 0 WBTC
        bytes4 selector1 = bytes4(keccak256("NullAmount()"));
        vm.expectRevert(selector1);
        lendpool.deposit(wbtc, 0, address(alice));

        // Alice deposits WBTC and set an invalid address to recieve uTokens
        bytes4 selector2 = bytes4(keccak256("InvalidAddress()"));
        vm.expectRevert(selector2);
        lendpool.deposit(wbtc, 2 * 1e8, address(0));

        // Alice deposits 2 WBTC
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

        vm.startPrank(alice);
        // Alice tries to withdraw more than 2 WBTC
        vm.expectRevert(bytes4(keccak256("NotEnoughBalance()")));
        lendpool.withdraw(wbtc, 3 * 1e8, address(alice));

        // Alice withdraws her 2 WBTC and burns her 2 Utokens
        lendpool.withdraw(wbtc, 2 * 1e8, address(alice));
        // Now alice has more than 2 WBTC (include rewards)
        assertGt(IERC20(wbtc).balanceOf(address(alice)), 2 * 1e8);
        assertEq(IERC20(address(utoken)).balanceOf(address(alice)), 0);
    }

    function testGetNftPrice() public view {
        // ask for Azuki NFT floor price
        uint256 price1 = lendpool.getNftPrice(azukiAgg);
        console.log(price1);

        // ask for Bored Ape Yacht CLub NFT floor price
        uint256 price2 = lendpool.getNftPrice(baycAgg);
        console.log(price2);

        // ask for BEANZ Official NFT floor price
        uint256 price3 = lendpool.getNftPrice(beanzAgg);
        console.log(price3);
    }


    function testBorrow() public {
        // Owner of the NFT Token Id 2150 from Bored Ape Yacht CLub
        address ownerToken2150 = IERC721(baycNFT).ownerOf(2150);
        // The owner send his NFT to alice
        vm.prank(ownerToken2150);
        IERC721(baycNFT).safeTransferFrom(ownerToken2150, address(alice), 2150);
        assertEq(IERC721(baycNFT).ownerOf(2150), address(alice));

        // Owner of the NFT Token Id 8035 from Azuki
        address ownerToken8035 = IERC721(azukiNFT).ownerOf(8035);
        // The owner send his NFT to alice
        vm.prank(ownerToken8035);
        IERC721(azukiNFT).safeTransferFrom(ownerToken8035, address(alice), 8035);
        assertEq(IERC721(azukiNFT).ownerOf(8035), address(alice));

        // Alice asks for a 1 WBTC loan using the BAYC NFT as collateral. She
        // must approve LendPool contract to move her NFT to Unft contract.
        // She will receive the uNFT Token with id 1
        vm.startPrank(alice);
        IERC721(baycNFT).approve(address(lendpool), 2150);
        lendpool.borrow(wbtc, 1 * 1e8, baycNFT, 2150);
        assertEq(IERC20(wbtc).balanceOf(address(alice)), 1 * 1e8);
        assertEq(IERC721(baycNFT).ownerOf(2150), address(uNFT));
        assertEq(IERC721(uNFT).ownerOf(1), address(alice));

        // Alice asks for a 0.1 WBTC loan using the Azuki NFT as collateral. She
        // must approve LendPool contract to move her NFT to Unft contract. An error
        // must revert due she has already asked for a WBTC loan.
        IERC721(azukiNFT).approve(address(lendpool), 8035);
        bytes4 selector = bytes4(keccak256("OnlyOneLoan()"));
        vm.expectRevert(selector);
        lendpool.borrow(wbtc, 0.1 * 1e8, azukiNFT, 8035);

        // Alice asks for a 200 LINK loan using the Azuki NFT as collateral
        // She will receive the uNFT Token with id 2
        console.log(lendpool.getNftPrice(azukiAgg));
        lendpool.borrow(link, 200 * 1e18, azukiNFT, 8035);
        assertEq(IERC721(azukiNFT).ownerOf(8035), address(uNFT));
        assertEq(IERC721(uNFT).ownerOf(2), address(alice));
    }
}

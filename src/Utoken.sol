// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "solmate/tokens/ERC20.sol";

contract Utoken is ERC20 {
    constructor() ERC20("Utokens", "UT", 18) {}

    function mint(address to, uint256 amount) public {
        require(amount > 0, "Invalid mint amount");
        _mint(to, amount);
    }

    function burn(
        address uTokenOwner,
        //address assetReceiver,
        uint256 amount
    ) public {
        require(amount > 0, "Invalid burn amount");
        // uTokens are burnt
        _burn(uTokenOwner, amount);
        // return to assetReceiver the asset deposited at LendPool
    }
}

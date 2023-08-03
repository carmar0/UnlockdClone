// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "solmate/tokens/ERC20.sol";

contract Utoken is ERC20 {

    constructor() ERC20("Utokens", "uToken", 18){}

    function mint(address to, uint256 amount) public {      
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public{      
        _burn(from, amount);
    }

}
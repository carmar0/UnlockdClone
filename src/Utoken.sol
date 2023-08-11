// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "solmate/tokens/ERC20.sol";

contract Utoken is ERC20 {

    address public lendPool; // falta poner la direccion 

    modifier onlyLendPool() {
        require(msg.sender == address(lendPool),"caller must be lendPool");
        _;
    }

    constructor() ERC20("Utokens", "uT", 18){}

    // falta aplicar modifier onlyLendPool en mint() y burn()
    function mint(address to, uint256 amount) public { 
         require(amount > 0, "Invalid amount");   
        _mint(to, amount);
    }

    function burn(
        address uTokenOwner,
        //address assetReceiver,
        uint256 amount
     ) public { 
        require(amount > 0, "Invalid amount");  
        // se queman los uTokens     
        _burn(uTokenOwner, amount);
        // se envia a assetReceiver el asset depositado en la LendPool
    }

}
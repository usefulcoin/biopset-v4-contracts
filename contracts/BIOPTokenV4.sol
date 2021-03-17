pragma solidity ^0.6.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./BIOPToken.sol";
contract BIOPTokenV4 is ERC20 {
    constructor(string memory name_, string memory symbol_) public ERC20(name_, symbol_) {
      _mint(msg.sender, 1300000300000000000000000000000);/*
      (✅ means a contract for this has been written)
      late bonding curve = 250000000000000000000000000000✅
      utilization rewards =650000000000000000000000000000✅
      swap =                    ?300000000000000000000000✅
      ITCO =               250000000000000000000000000000✅
      DEX rewards =         80000000000000000000000000000 TODO
      dev fund =            70000000000000000000000000000
      */
    }

    /**
    * @dev enables DAO to burn tokens 
    * @param amount the amount of tokens to burn
    */
    function burn(uint256 amount) public {
      require(balanceOf(msg.sender) >= amount, "insufficent balance");
      _burn(msg.sender, amount);
    }
}

pragma solidity ^0.6.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./BIOPToken.sol";
contract BIOPTokenV4 is ERC20 {
    bool public whitelistEnabled = false;
    mapping(address payable=>bool) whitelist;
    address public owner;

    constructor(string memory name_, string memory symbol_) public ERC20(name_, symbol_) {
      _mint(msg.sender, 1300000300000000000000000000000);
      /*
      (✅ means a contract for this has been written)
      late bonding curve = 250000000000000000000000000000✅
      utilization rewards =650000000000000000000000000000✅
      swap =                    ?300000000000000000000000✅
      ITCO =               250000000000000000000000000000✅
      DEX rewards =         80000000000000000000000000000 TODO
      dev fund =            70000000000000000000000000000
      */
      whitelistEnabled = true;
      whitelist[msg.sender] = true;
    }

     /**
    * @dev enables DAO to burn tokens 
    * @param amount the amount of tokens to burn
    */
    function burn(uint256 amount) public {
      require(balanceOf(msg.sender) >= amount, "insufficent balance");
      _burn(msg.sender, amount);
    }

    //Temp whitelist functionality

  /**
   * @dev Reverts if called by anyone other than the contract owner.
   */
    modifier onlyOwner() {
      require(msg.sender == owner, "Only callable by owner");
      _;
    }

    function transferOwner(address payable newOwner_) public onlyOwner {
      owner = newOwner_;
    }


    function addToWhitelist(address payable) public onlyOwner {
      whitelist[address] = true;
    }

    function removeFromWhitelist(address payable) public onlyOwner {
      whitelist[address] = false;
    }

    function disableWhitelist() public onlyOwner {
      whitelistEnabled = false;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {      
      if (whitelistEnabled) {
        require(whitelist[_msgSender()] == true, "unapproved sender");
      }
      _approve(_msgSender(), spender, amount);
      return true;
    }


}

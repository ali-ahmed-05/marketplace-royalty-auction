// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SnapbackToken is ERC20, ERC20Permit, Ownable {
    constructor(uint256 supply) ERC20("SnapToken", "SBT") ERC20Permit("SnapToken") {
         _mint(_msgSender(), supply);
    }
}
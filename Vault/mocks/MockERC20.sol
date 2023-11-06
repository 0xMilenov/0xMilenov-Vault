// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "openzeppelin/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, 1000000 * 10 ** 18); // Mint 1,000,000 tokens for testing
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "openzeppelin/token/ERC20/ERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {MockERC20} from "../mocks/MockERC20.sol";

contract VaultTest is Test {
    Vault private vault;
    MockERC20 private token;
    address private deployer;
    address private user;

    function setUp() public {
        // Set up the test environment
        deployer = address(this);
        user = address(0x1);

        token = new MockERC20("MockToken", "MKT");
        vault = new Vault(token);

        token.approve(address(vault), type(uint256).max);
        vm.startPrank(user);
        token.mint(user, 1000 * 10 ** 18); // Mint 1000 tokens for the user
        token.approve(address(vault), type(uint256).max);
        vm.stopPrank();
    }

    function testInitialBalance() public {
        // Users should start with 0 shares in the vault
        assertEq(vault.balanceOf(user), 0);
    }

    function testDeposit() public {
        // User deposits 100 tokens into the vault
        uint256 depositAmount = 100 * 10 ** 18;
        vm.startPrank(user);
        uint256 userBalanceBefore = token.balanceOf(user);
        vault.deposit(depositAmount);
        uint256 userBalanceAfter = token.balanceOf(user);

        // Check the user's token balance has decreased by the deposit amount
        assertEq(userBalanceBefore - depositAmount, userBalanceAfter);
        // Check the user's share balance in the vault has increased
        assertEq(vault.balanceOf(user), depositAmount);
        vm.stopPrank();
    }

    function testWithdraw() public {
        // User deposits 100 tokens and then withdraws 50
        uint256 depositAmount = 100 * 10 ** 18;
        uint256 withdrawAmount = 50 * 10 ** 18;
        vm.startPrank(user);
        vault.deposit(depositAmount);

        uint256 userSharesBefore = vault.balanceOf(user);
        vault.withdraw(withdrawAmount);
        uint256 userSharesAfter = vault.balanceOf(user);
        uint256 userTokenBalance = token.balanceOf(user);

        // Check the user's share balance has decreased by the withdraw amount
        assertEq(userSharesBefore - withdrawAmount, userSharesAfter);
        // Check the user's token balance has increased after withdrawal
        assertTrue(userTokenBalance > depositAmount - withdrawAmount);
        vm.stopPrank();
    }
}

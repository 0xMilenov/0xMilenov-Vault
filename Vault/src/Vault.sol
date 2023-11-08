// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/utils/ReentrancyGuard.sol";

/**
 * @title 0xMilenov Vault
 * @dev A lending vault that mints shares to depositors and burns shares from withdrawers
 * @notice Assignment-1
 * @author 0xMilenov
 */
contract Vault is ReentrancyGuard, Ownable {
    // @notice SafeERC20 wrapper for IERC20
    using SafeERC20 for IERC20;

    // @notice Address of the asset token
    IERC20 public immutable token;

    // @notice Total supply of shares
    uint public totalSupply;

    // @notice Internal accounting of the vault's token balance
    uint256 private _vaultBalance;

    // @notice Mapping of user address to their balance
    mapping(address => uint) public balanceOf;

    // @notice Emitted when a user mints shares
    event Mint(address indexed to, uint amount);

    // @notice Emitted when a user burns shares
    event Burn(address indexed from, uint amount);

    // @notice Emitted when a user deposits tokens into the vault
    event Deposit(address indexed from, uint amount);

    // @notice Emitted when a user withdraws tokens from the vault
    event Withdraw(address indexed to, uint amount);

    // @notice Error messages
    error ZeroAddressNotAllowed();
    error ZeroAmountNotAllowed();
    error InsufficientBalance();
    error TokenDecimalsMustBeLessThan18();
    error InsufficientSharesMinted();

    /**
     * @notice Constructor
     * @param _token - address of the asset token
     */
    constructor(IERC20 _token) Ownable(msg.sender) {
        if (address(_token) == address(0)) {
            revert ZeroAddressNotAllowed();
        }

        if (ERC20(address(_token)).decimals() > 18) {
            revert TokenDecimalsMustBeLessThan18();
        }

        token = _token;
        _vaultBalance = 0;
    }

    /**
     * @notice Mints shares to user
     * @param _to - address of user to mint shares to
     * @param _shares - amount of shares to mint
     */
    function _mint(address _to, uint _shares) public {
        totalSupply += _shares;
        balanceOf[_to] += _shares;

        emit Mint(_to, _shares);
    }

    /**
     * @notice Burns shares from user
     * @param _from - address of user to burn shares from
     * @param _shares - amount of shares to burn
     */
    function _burn(address _from, uint _shares) public {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;

        emit Burn(_from, _shares);
    }

    /**
     * @notice Deposits amount into lending vault and mint shares to user
     * @param _amount - amount of asset tokens to deposit in token units
     * @param _minSharesAmt - Minimum amount of shares tokens to receive on deposit
     */
    function deposit(uint _amount, uint _minSharesAmt) external nonReentrant {
        if (_amount == 0) {
            revert ZeroAmountNotAllowed();
        }

        uint shares;
        if (totalSupply == 0 || _vaultBalance == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / _vaultBalance;
        }

        token.safeTransferFrom(msg.sender, address(this), _amount);
        _vaultBalance += _amount;
        _mint(msg.sender, shares);

        if (shares < _minSharesAmt) {
            revert InsufficientSharesMinted();
        }

        emit Deposit(msg.sender, _amount);
    }

    /**
     * @notice Withdraws asset from lending vault, burns shares from user
     * @param _shares - amount of shares to burn
     */
    function withdraw(uint _shares) external nonReentrant {
        if (_shares == 0) {
            revert ZeroAmountNotAllowed();
        }
        if (_shares > balanceOf[msg.sender]) {
            revert InsufficientBalance();
        }

        uint amount = (_shares * _vaultBalance) / totalSupply;
        _burn(msg.sender, _shares);
        _vaultBalance -= amount;
        token.safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }
}

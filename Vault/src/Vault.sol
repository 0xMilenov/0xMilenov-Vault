// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable2Step.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";

/**
 * @title 0xMilenov Vault
 * @dev A lending vault that mints shares to depositors and burns shares from withdrawers
 * @notice Assignment-1
 * @author 0xMilenov
 */
contract Vault is ERC20, ReentrancyGuard, Ownable2Step {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;

    uint public totalSupply;

    mapping(address => uint) public balanceOf;

    // @notice Emitted when a user deposits tokens into the vault
    event Deposit(address indexed from, uint amount);

    // @notice Emitted when a user withdraws tokens from the vault
    event Withdraw(address indexed to, uint amount);

    // Error messages
    error ZeroAddressNotAllowed();
    error ZeroAmountNotAllowed();
    error InsufficientBalance();

    /**
     * param _name - name of the vault token
     * param _symbol - symbol of the vault token
     * param _token - address of the asset token
     */
    constructor(
        string memory _name,
        string memory _symbol,
        IERC20 _token
    ) ERC20(_name, _symbol) Ownable(msg.sender) {
        if (address(_token) == address(0)) {
            revert ZeroAddressNotAllowed();
        }

        token = IERC20(_token);
    }

    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }

    /**
     * @notice Deposits amount into lending vault and mint shares to user
     * @param _amount - amount of asset tokens to deposit in token units
     */
    function deposit(uint _amount) external nonReentrant {
        /*
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */

        // amount + total need to be < max capacity

        if (_amount == 0) {
            revert ZeroAmountNotAllowed();
        }

        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        token.safeTransferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, shares);

        emit Deposit(msg.sender, _amount);
    }

    /**
     * @notice Withdraws asset from lending vault, burns token from user
     * @param _shares - Amount of tokens to burn in token units
     */
    function withdraw(uint _shares) external nonReentrant {
        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn

        (T - s) / T = (B - a) / B 

        a = sB / T
        */

        if (_shares == 0) {
            revert ZeroAmountNotAllowed();
        }
        if (_shares > balanceOf[msg.sender]) {
            revert InsufficientBalance();
        }

        uint amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        token.safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }
}

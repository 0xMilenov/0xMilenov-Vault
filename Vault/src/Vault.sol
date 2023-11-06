// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";

/**
 * @title 0xMilenov Vault
 * @dev A lending vault that mints shares to depositors and burns shares from withdrawers
 * @notice Assignment-1
 * @author 0xMilenov
 */
contract Vault {
    IERC20 public immutable token;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    /**
     * @notice Emitted when a user deposits tokens into the vault
     */
    event Deposit(address indexed from, uint amount);

    /**
     * @notice Emitted when a user withdraws tokens from the vault
     */
    event Withdraw(address indexed to, uint amount);

    constructor(address _token) {
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
    function deposit(uint _amount) external {
        /*
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */
        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _amount);
    }

    /**
     * @notice Withdraws asset from lending vault, burns token from user
     * @param _shares - Amount of tokens to burn in token units
     */
    function withdraw(uint _shares) external {
        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn

        (T - s) / T = (B - a) / B 

        a = sB / T
        */
        uint amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }
}

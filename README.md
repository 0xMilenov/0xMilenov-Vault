# 0xMilenov Vault

## Introduction

The Vault is a state-of-the-art lending vault implemented in Solidity and designed to run on the Ethereum blockchain.      
It leverages widely recognized security practices and has been audited to ensure it conforms to industry standards.          
This vault operates by minting and burning share tokens in response to user deposits and withdrawals, respectively.      

## Features

- The vault supports any ERC20 compliant token.
- Secured against reentrancy attacks for safety in transaction ordering.
- Utilizes OpenZeppelin's Ownable for administrative actions.
- The shares are standard ERC20 tokens, ensuring wide compatibility.

## Security

- The contract follows the best security patterns.
- It uses SafeERC20 from OpenZeppelin to safely interact with ERC20 tokens.
- Inherits ReentrancyGuard to protect against reentrancy attacks.

## Setup and Deployment

To deploy the Vault, you will need an Ethereum wallet and enough ETH to cover the deployment gas fees.      
You will also need the address of the ERC20 token you wish to use with the vault.

Update the .env file with your wallet information and RPC URL.        
Run truffle migrate to deploy the contracts to the desired network.

## Interacting with the Contract

- **Deposit**: To deposit tokens, call the deposit function with the amount and the minimum shares you wish to mint.          
- **Withdraw**: To withdraw tokens, call the withdraw function with the amount of shares you wish to burn.              
**Ensure that you approve the vault to spend your ERC20 tokens before interacting with the deposit function**.

## Contributing
We welcome contributions from the community. If you find a bug or have a feature request, please open an issue or create a pull request.

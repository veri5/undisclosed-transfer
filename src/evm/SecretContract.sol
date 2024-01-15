// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Gateway } from "./Gateway.sol";

contract SecretContract {
    Gateway public gateway;

    mapping(address => uint256) public balances;

    /**
     * @dev Constructor function to initialize the contract with the Gateway address.
     * @param gatewayAddress The address of the Gateway contract.
     */
    constructor(address gatewayAddress) {
        gateway = Gateway(gatewayAddress);
    }

    /**
     * @dev Transfers funds from sender to recipient, triggering a call to the Gateway contract.
     * @param sender The address of the sender initiating the transfer.
     * @param recipient The address of the recipient receiving the transfer.
     * @param amount The amount of funds to transfer.
     */
    function transfer(address sender, address recipient, uint256 amount) external {
        require(sender != address(0), "Invalid sender address");
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than zero");
        require(balances[sender] >= amount, "Insufficient balance");

        // ToDo: Verify Sender's signature

        balances[sender] -= amount;

        bytes memory payload = abi.encode(recipient, amount);
        gateway.callEvmContract(payload);
    }

    /**
     * @dev Executes a transfer by updating the balance of the provided sender with the given amount.
     * @param payload The payload containing sender and amount information.
     */
    function _execute(
        string calldata /*sourceChain*/,
        string calldata /*sourceAddress*/,
        bytes calldata payload
    ) external {
        (address sender, uint256 amount) = abi.decode(payload, (address, uint256));

        require(sender != address(0), "Invalid sender address");
        require(amount > 0, "Withdrawal amount must be greater than zero");

        balances[sender] += amount;
    }
}
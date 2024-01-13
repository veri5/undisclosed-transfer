// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Gateway } from "./Gateway.sol";

contract SecretContract {
    Gateway public gateway;

    mapping(address => uint256) public balances;

    constructor(address gatewayAddress) {
        gateway = Gateway(gatewayAddress);
    }

    function transfer(address sender, address recipient, uint256 amount) external {
        require(sender != address(0), "Invalid sender address");
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than zero");
        require(balances[sender] >= amount, "Insufficient balance");

        // ToDo: Verify Sender's signature

        balances[sender] -= amount;

        bytes memory payload = abi.encode(recipient, amount);
        gateway._executePublic("", "", payload);
    }

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
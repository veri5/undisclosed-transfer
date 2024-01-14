// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Escrow } from "./Escrow.sol";
import { Gateway } from "./Gateway.sol";

contract EvmContract {
    Escrow public escrow;
    Gateway public gateway;

    constructor(address escrowAddress, address gatewayAddress) {
        escrow = Escrow(escrowAddress);
        gateway = Gateway(gatewayAddress);
    }

    function deposit(address sender) external payable {
        require(sender != address(0), "Invalid sender address");
        require(msg.value > 0, "Deposit amount must be greater than zero");

        escrow.deposit{value: msg.value}();

        bytes memory payload = abi.encode(sender, msg.value);
        gateway.callSecretContract(payload);
    }

    function _execute(
        string calldata /*sourceChain*/,
        string calldata /*sourceAddress*/,
        bytes calldata payload
    ) external {
        (address recipient, uint256 amount) = abi.decode(payload, (address, uint256));

        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Withdrawal amount must be greater than zero");

        escrow.withdraw(recipient, amount);
    }
}
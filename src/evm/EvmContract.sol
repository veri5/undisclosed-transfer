// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Escrow } from "./Escrow.sol";
import { Gateway } from "./Gateway.sol";

contract EvmContract {
    Escrow public escrow;
    Gateway public gateway;

    /**
     * @dev Constructor function to initialize the contract with escrow and gateway addresses.
     * @param escrowAddress The address of the Escrow contract.
     * @param gatewayAddress The address of the Gateway contract.
     */
    constructor(address escrowAddress, address gatewayAddress) {
        escrow = Escrow(escrowAddress);
        gateway = Gateway(gatewayAddress);
    }

    /**
     * @dev Deposits funds into the escrow and triggers a call to the Gateway contract.
     * @param sender The address of the sender initiating the deposit.
     */
    function deposit(address sender) external payable {
        require(sender != address(0), "Invalid sender address");
        require(msg.value > 0, "Deposit amount must be greater than zero");

        escrow.deposit{value: msg.value}();

        bytes memory payload = abi.encode(sender, msg.value);
        gateway.callSecretContract(payload);
    }

    /**
     * @dev Executes a withdrawal from the escrow based on the provided payload.
     * @param sourceChain The source chain identifier (not used in the current implementation).
     * @param sourceAddress The source address (not used in the current implementation).
     * @param payload The payload containing recipient and amount information.
     */
    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external {
        (address recipient, uint256 amount) = abi.decode(payload, (address, uint256));

        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Withdrawal amount must be greater than zero");

        escrow.withdraw(recipient, amount);
    }
}
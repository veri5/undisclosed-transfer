// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Escrow } from "./Escrow.sol";

contract Gateway {
    EvmContract evmContract;
    SecretContract secretContract;

    function setContracts(address evmContractAddress, address secretContractAddress) external {
        evmContract = EvmContract(evmContractAddress);
        secretContract = SecretContract(secretContractAddress);
    }

    function _executeSecret(
        string calldata /*sourceChain*/,
        string calldata /*sourceAddress*/,
        bytes calldata payload
    ) external {
        secretContract._execute("", "", payload);
    }

    function _executePublic(
        string calldata /*sourceChain*/,
        string calldata /*sourceAddress*/,
        bytes calldata payload
    ) external {
        evmContract._execute("", "", payload);
    }
}

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
        gateway._executeSecret("", "", payload);
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
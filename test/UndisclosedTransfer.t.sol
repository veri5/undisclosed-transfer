// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { Escrow } from "../src/evm/Escrow.sol";
import { Gateway, EvmContract, SecretContract } from "../src/evm/UndisclosedTransfer.sol";

contract UndisclosedTransferTest is Test {
    Gateway gateway;
    EvmContract evmContract;
    SecretContract secretContract;

    address escrowAddress;
    address gatewayAddress;

    uint256 constant DEPOSIT_AMOUNT = 1000 ether;
    uint256 constant TRANSFER_AMOUNT = 200 ether;

    address sender;
    address recipient;

    function setUp() public {
        escrowAddress = address(new Escrow(makeAddr("owner")));
        gateway = new Gateway();
        gatewayAddress = address(gateway);
        evmContract = new EvmContract(escrowAddress, gatewayAddress);
        secretContract = new SecretContract(gatewayAddress);
        gateway.setContracts(address(evmContract), address(secretContract));
        sender = makeAddr("sender");
        recipient = makeAddr("recipient");
    }

    function testDeposit() public {
        evmContract.deposit{value: DEPOSIT_AMOUNT}(sender);

        assertEq(secretContract.balances(sender), DEPOSIT_AMOUNT, "Sender balance should increase after deposit");
    }

    function testTransfer() public {
        evmContract.deposit{value: DEPOSIT_AMOUNT}(sender);

        secretContract.transfer(sender, recipient, TRANSFER_AMOUNT);

        assertEq(secretContract.balances(sender), DEPOSIT_AMOUNT - TRANSFER_AMOUNT, "Sender balance should decrease");
        assertEq(address(recipient).balance, TRANSFER_AMOUNT, "Recipient should now hold TRANSFER_AMOUNT");
    }
}

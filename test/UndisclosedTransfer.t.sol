// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { Escrow } from "../src/evm/Escrow.sol";
import { Gateway } from "../src/evm/Gateway.sol";
import { EvmContract } from "../src/evm/EvmContract.sol";
import { SecretContract } from "../src/evm/SecretContract.sol";

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

    /** 
     * @dev Set up the test environment by deploying necessary contracts and initializing addresses.
     */
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

    /** 
     * @dev Test the deposit functionality.
     */
    function testDeposit() public {
        // Deposit funds into the EvmContract
        evmContract.deposit{value: DEPOSIT_AMOUNT}(sender);

        // Check if the Secret balance of the sender has increased
        assertEq(secretContract.balances(sender), DEPOSIT_AMOUNT, "Sender Secret balance should increase after deposit");
        
        // Check if the EVM balance of the sender is now 0
        assertEq(address(sender).balance, 0, "Sender EVM balance should be 0 after deposit");
    }

    /** 
     * @dev Test the transfer functionality.
     */
    function testTransfer() public {
        // Deposit funds into the EvmContract
        evmContract.deposit{value: DEPOSIT_AMOUNT}(sender);

        // Perform a transfer from sender to recipient
        secretContract.transfer(sender, recipient, TRANSFER_AMOUNT);

        // Check if the Secret balance of the sender has decreased
        assertEq(secretContract.balances(sender), DEPOSIT_AMOUNT - TRANSFER_AMOUNT, "Sender Secret balance should decrease after transfer");
        
        // Check if the EVM balance of the recipient is now TRANSFER_AMOUNT
        assertEq(address(recipient).balance, TRANSFER_AMOUNT, "Recipient EVM balance should be TRANSFER_AMOUNT after transfer");
    }

    /** 
     * @dev Test the case where the transfer amount exceeds the sender's Secret balance.
     */
    function testTransferExceedSecretBalance() public {
        // Deposit funds into the EvmContract
        evmContract.deposit{value: DEPOSIT_AMOUNT}(sender);

        // Attempt a transfer with an amount exceeding the Secret balance
        vm.expectRevert("Insufficient balance");
        secretContract.transfer(sender, recipient, DEPOSIT_AMOUNT + 1);
    }

    /** 
     * @dev Test the case where a transfer is attempted without a prior deposit.
     */
    function testTransferWithoutDeposit() public {
        // Attempt a transfer without a prior deposit
        vm.expectRevert("Insufficient balance");
        secretContract.transfer(sender, recipient, TRANSFER_AMOUNT);
    }
}
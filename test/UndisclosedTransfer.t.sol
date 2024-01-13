// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { Escrow } from "../src/evm/Escrow.sol";
import { Gateway, PublicSide, SecretSide } from "../src/evm/UndisclosedTransfer.sol";

contract UndisclosedTransferTest is Test {
    Gateway gateway;
    PublicSide publicSide;
    SecretSide secretSide;

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
        publicSide = new PublicSide(escrowAddress, gatewayAddress);
        secretSide = new SecretSide(gatewayAddress);
        gateway.setContracts(address(publicSide), address(secretSide));
        sender = makeAddr("sender");
        recipient = makeAddr("recipient");
    }

    function testTransfer() public {
        publicSide.deposit{value: DEPOSIT_AMOUNT}(sender);

        secretSide.transfer(sender, recipient, TRANSFER_AMOUNT);

        assertEq(secretSide.balances(sender), DEPOSIT_AMOUNT - TRANSFER_AMOUNT, "Sender balance should decrease");
        assertEq(address(recipient).balance, TRANSFER_AMOUNT, "Recipient should now hold TRANSFER_AMOUNT");
    }
}

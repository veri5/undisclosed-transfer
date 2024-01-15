// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { Escrow } from "../src/evm/Escrow.sol";
import { EvmContract } from "../src/evm/EvmContract.sol";
import { SecretContract } from "../src/evm/SecretContract.sol";
import { Gateway } from "../src/evm/Gateway.sol";

contract UndisclosedTransferScript is Script {
    Escrow public escrow;
    Gateway public gateway;
    EvmContract public evmContract;
    SecretContract public secretContract;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address initialOwner = address(bytes20(bytes(vm.envString("PUBLIC_ADDRESS"))));

        vm.startBroadcast(privateKey);
        
        escrow = new Escrow(initialOwner);
        gateway = new Gateway();
        evmContract = new EvmContract(address(escrow), address(gateway));
        secretContract = new SecretContract(address(gateway));
        gateway.setContracts(address(evmContract), address(secretContract));

        vm.stopBroadcast();

        console.log("Escrow deployed at:", address(escrow));
        console.log("Gateway deployed at:", address(gateway));
        console.log("EvmContract deployed at:", address(evmContract));
        console.log("SecretContract deployed at:", address(secretContract));
    }
}
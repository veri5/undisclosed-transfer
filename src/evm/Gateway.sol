// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { EvmContract } from "./EvmContract.sol";
import { SecretContract } from "./SecretContract.sol";

contract Gateway {
    EvmContract evmContract;
    SecretContract secretContract;

    function setContracts(
        address evmContractAddress, 
        address secretContractAddress
    ) external {
        evmContract = EvmContract(evmContractAddress);
        secretContract = SecretContract(secretContractAddress);
    }

    function callSecretContract(
        bytes calldata payload
    ) external {
        secretContract._execute("", "", payload);
    }

    function callEvmContract(
        bytes calldata payload
    ) external {
        evmContract._execute("", "", payload);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { EvmContract } from "./EvmContract.sol";
import { SecretContract } from "./SecretContract.sol";

/**
 * @title Gateway
 * @dev Smart contract serving as a gateway between EvmContract and SecretContract.
 */
contract Gateway {
    EvmContract evmContract;
    SecretContract secretContract;

    /**
     * @dev Sets the addresses of EvmContract and SecretContract.
     * @param evmContractAddress The address of the EvmContract.
     * @param secretContractAddress The address of the SecretContract.
     */
    function setContracts(
        address evmContractAddress, 
        address secretContractAddress
    ) external {
        evmContract = EvmContract(evmContractAddress);
        secretContract = SecretContract(secretContractAddress);
    }

    /**
     * @dev Calls the _execute function of SecretContract with the provided payload.
     * @param payload The payload to be passed to SecretContract.
     */
    function callSecretContract(
        bytes calldata payload
    ) external {
        secretContract._execute("", "", payload);
    }

    /**
     * @dev Calls the _execute function of EvmContract with the provided payload.
     * @param payload The payload to be passed to EvmContract.
     */
    function callEvmContract(
        bytes calldata payload
    ) external {
        evmContract._execute("", "", payload);
    }
}
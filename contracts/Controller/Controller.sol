// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "./Signer.sol";

/**
 * @title FOController
 * @dev This contract serves as the Controller in the Oracle system.
 * It inherits from the Signer contract.
 */
contract FOController is Signer {  

    /**
     * @dev Constructor function to initialize the FOController contract.
     * @param _owner The address of the contract owner.
     * @param _seed A seed value used for cryptographic purposes.
     * @param _apiPubKeySigner The address of the API public key signer.
     */
    constructor(address _owner, uint16 _seed, address _apiPubKeySigner) Signer(_owner,_seed, _apiPubKeySigner)  {}


}

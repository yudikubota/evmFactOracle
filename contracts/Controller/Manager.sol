// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "./Oracles.sol";

/**
 * @title Manager
 * @dev This contract contrle the managers within the Oracle system.
 */
contract Manager is Oracles {

    mapping(address => bool) private managerList;

    /**
     * @dev Constructor function to initialize the Manager contract.
     * @param _owner The address of the contract owner.
     */
    constructor(address _owner) Oracles(_owner) {
        addManager(_owner);
    }

    /**
     * @dev Adds a new manager.
     * @param _address The address of the new manager.
     */
    function addManager(address _address) public onlyOwner {
        managerList[_address] = true;
    }

    /**
     * @dev Removes an existing manager.
     * @param _address The address of the manager to be removed.
     */
    function dropManager(address _address) public onlyOwner {
        delete managerList[_address];
    }

    /**
     * @dev Checks if an address is a manager.
     * @param _address The address to be checked.
     * @return A boolean indicating whether the address is a manager.
     */
    function isManager(address _address) public view returns (bool) {
        return _address == address(this) || managerList[_address];
    }
}

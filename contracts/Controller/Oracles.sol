// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;
import "./Nodes.sol";

/**
 * @title Oracles
 * @dev This contract manages the oracles in the Oracle system.
 * It inherits from the Nodes contract.
 */
contract Oracles is Nodes {
   
    mapping(address => bool) private oracleList;

    /**
     * @dev Constructor function to initialize the Oracles contract.
     * @param _owner The address of the contract owner.
     */
    constructor(address _owner) Nodes(_owner) {}

    /**
     * @dev Adds a new oracle.
     * @param _address The address of the new oracle.
     */
    function addOracle(address _address) public onlyOwner {
        oracleList[_address] = true;
    }

    /**
     * @dev Removes an existing oracle.
     * @param _address The address of the oracle to be removed.
     */
    function dropOracle(address _address) public onlyOwner {
        delete oracleList[_address];
    }

    /**
     * @dev Checks if an address is an oracle.
     * @param _address The address to be checked.
     * @return A boolean indicating whether the address is an oracle.
     */
    function isOracle(address _address) public view returns (bool) {
        return oracleList[_address];
    }
    
}

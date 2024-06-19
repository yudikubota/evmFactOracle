// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;
import "../Helpers/Control.sol";

/**
 * @title FODataNode
 * @dev Contract for managing data storage and retrieval.
 */
contract FODataNode is Control {
    // Mapping to store packed data values by feed ID
    mapping(uint32 => PackDataValue) private packDataList;
    // Mapping to store integer data values by feed ID
    mapping(uint32 => IntDataValue) private intDataList;

    /**
     * @dev Constructor to initialize the FODataNode contract with a controller address.
     * @param _controller The address of the controller contract.
     */
    constructor(address _controller) Control(_controller) {}

    /**
     * @dev Function to store integer data.
     * @param _dataItem The data item containing the information to be stored.
     */
    function store(IntDataItem calldata _dataItem) public {
        // Require that the caller is a manager
        require(controller.isManager(msg.sender), 'Operation not allowed');        
        // Store the integer data value in the IntDataList mapping
        intDataList[_dataItem.feedId] = IntDataValue(_dataItem.lastUpdate, _dataItem.value, _dataItem.decimal);
    }

    /**
     * @dev Function to read integer data.
     * @param _feedId The ID of the data feed to be read.
     * @return dataValue The data value associated with the specified feed ID.
     */
    function readInt(uint32 _feedId) public view returns (IntDataValue memory dataValue) {
        // Require that the caller is an oracle
        require(controller.isOracle(msg.sender), 'Operation not allowed');        
        // Retrieve and return the integer data value associated with the feed ID
        dataValue = intDataList[_feedId]; 
    }

    /**
     * @dev Function to store packed data.
     * @param _dataItem The data item containing the information to be stored.
     */
    function storePack(PackDataItem calldata _dataItem) public {
        // Require that the caller is a manager
        require(controller.isManager(msg.sender), 'Operation not allowed');        
        // Store the packed data value in the PackDataList mapping
        packDataList[_dataItem.feedId] = PackDataValue(_dataItem.lastUpdate, _dataItem.value, _dataItem.decimal);
    }

    /**
     * @dev Function to read packed data.
     * @param _feedId The ID of the data feed to be read.
     * @return dataValue The data value associated with the specified feed ID.
     */
    function readPack(uint32 _feedId) public view returns (PackDataValue memory dataValue) {
        // Require that the caller is an oracle
        require(controller.isOracle(msg.sender), 'Operation not allowed');        
        // Retrieve and return the packed data value associated with the feed ID
        dataValue = packDataList[_feedId]; 
    }
}

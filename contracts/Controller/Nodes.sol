// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../Helpers/DataTypes.sol";

/**
 * @title Nodes
 * @dev This contract manages the nodes in the Oracle system.
 */
contract Nodes is Ownable {
    mapping(uint16 => address) private nodeList;
    mapping(uint32 => uint16) private feedNodeList;

    /**
     * @dev Constructor function to initialize the Nodes contract.
     * @param _owner The address of the contract owner.
     */
    constructor(address _owner) Ownable(_owner) {}

    /**
     * @dev Adds a new node.
     * @param _nodeId The ID of the new node.
     * @param _address The address of the new node.
     */
    function addNode(uint16 _nodeId, address _address) public onlyOwner {
        nodeList[_nodeId] = _address;
    }

    /**
     * @dev Removes an existing node.
     * @param _nodeId The ID of the node to be removed.
     */
    function dropNode(uint16 _nodeId) public onlyOwner {
        delete nodeList[_nodeId];
    }

    /**
     * @dev Assigns a node to a data feed.
     * @param _feedId The ID of the data feed.
     * @param _nodeId The ID of the node to be assigned.
     */
    function assignFeedNode(uint32 _feedId, uint16 _nodeId) public onlyOwner {
        feedNodeList[_feedId] = _nodeId;
    }

    /**
     * @dev Unlinks a node from a data feed.
     * @param _feedId The ID of the data feed.
     */
    function unlinkFeedNode(uint32 _feedId) public onlyOwner {
        delete feedNodeList[_feedId];
    }

    /**
     * @dev Retrieves the address of the node providing data for a given feed.
     * @param _feedId The ID of the data feed.
     * @return The address of the node providing data for the feed.
     */
    function getDataNodeFeed(uint32 _feedId) public view returns (address) {        
        uint16 nodeId = feedNodeList[_feedId];
        return nodeList[nodeId];
    }
}

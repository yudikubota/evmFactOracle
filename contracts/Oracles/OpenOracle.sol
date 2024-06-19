// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;
import "../Helpers/Control.sol";
import "../Helpers/DataNodeInterface.sol";

/**
 * @title OpenOracle
 * @dev Contract for accessing data from licensed feeds.
 */
contract OpenOracle is Control {
       
    uint8 private license; // License type for accessing data

    /**
     * @dev Constructor to initialize the OpenOracle contract with a controller address and license type.
     * @param _controller The address of the controller contract.
     * @param _license The license type required for accessing data.
     */
    constructor(address _controller, uint8 _license) Control(_controller) {
        license = _license;
    }    

    /**
     * @dev Function to check if a feed is available.
     * @param _feedId The ID of the data feed to check.
     * @return A boolean indicating whether the feed is available.
     */
    function isFeedAvailable(uint32 _feedId) public view returns (bool) {
        IntDataValue memory item = getFeed(_feedId);              
        return item.lastUpdate > 0;
    }

    /**
     * @dev Function to get the value of an integer data feed.
     * @param _feedId The ID of the data feed.
     * @return The value of the data feed.
     */
    function getValue(uint32 _feedId) public view returns (int256) {
        IntDataValue memory item = getFeed(_feedId);              
        return (item.value);
    }

    /**
     * @dev Function to get the data of an integer data feed.
     * @param _feedId The ID of the data feed.
     * @return _feed The data value associated with the specified feed ID.
     */
    function getFeed(uint32 _feedId) public view returns (IntDataValue memory _feed) {   
        // Verify license and retrieve data node address
        (bool status, address dnAddress, ) = controller.verifyLicense(_feedId, license);
        require(status, 'Request not allowed. Try the Subscription Oracle');
        // Read integer data from the data node
        _feed = IFODataNode(dnAddress).readInt(_feedId);
    }

    /**
     * @dev Function to check if a packed feed is available.
     * @param _feedId The ID of the data feed to check.
     * @return A boolean indicating whether the feed is available.
     */
    function isPackFeedAvailable(uint32 _feedId) public view returns (bool) {
        PackDataValue memory item = getPackFeed(_feedId);              
        return item.lastUpdate > 0;
    }

    /**
     * @dev Function to get the data of a packed data feed.
     * @param _feedId The ID of the data feed.
     * @return _feed The data value associated with the specified feed ID.
     */
    function getPackFeed(uint32 _feedId) public view returns (PackDataValue memory _feed) {   
        // Verify license and retrieve data node address
        (bool status, address dnAddress, ) = controller.verifyLicense(_feedId, license);
        require(status, 'Request not allowed');
        // Read packed data from the data node
        _feed = IFODataNode(dnAddress).readPack(_feedId);
    }    

    /**
     * @dev Function to verify the signature of an integer data feed.
     * @param _dataFeed The data feed item containing the information to be verified.
     * @return A boolean indicating whether the signature is valid.
     */
    function verify(IntDataItem calldata _dataFeed) public view returns (bool) {
        // Verify license for the feed
        (bool status, , ) = controller.verifyLicense(_dataFeed.feedId, license);
        require(status, 'This Feed is not licensed on this Oracle. Try the Subscription Oracle');
        // Verify the signature of the data feed
        return controller.verifySignInt(_dataFeed);
    }

    /**
     * @dev Function to verify the signature of a packed data feed.
     * @param _dataFeed The data feed item containing the information to be verified.
     * @return A boolean indicating whether the signature is valid.
     */
    function verifyPack(PackDataItem calldata _dataFeed) public view returns (bool) {        
        // Verify license for the feed
        (bool status, , ) = controller.verifyLicense(_dataFeed.feedId, license);
        require(status, 'This Feed is not licensed on this Oracle. Try the Subscription Oracle');
        // Verify the signature of the data feed
        return controller.verifySignPack(_dataFeed);
    }
}

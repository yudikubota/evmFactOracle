// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

// Importing Control contract for access control
import "../Helpers/Control.sol";
// Importing DataNodeInterface for interacting with data nodes
import "../Helpers/DataNodeInterface.sol";
// Importing Subscriber for managing subscriptions
import "../Helpers/Subscriber.sol";

/**
 * @title SubscriptionOracle
 * @dev Contract for accessing data from licensed feeds with subscription model.
 */
contract SubscriptionOracle is Control, Subscriber {

    uint8 private license; // License type required for accessing data

    /**
     * @dev Constructor to initialize the SubscriptionOracle contract with a controller address and license type.
     * @param _controller The address of the controller contract.
     * @param _license The license type required for accessing data.
     */
    constructor(address _controller, uint8 _license) Control(_controller) {
        license = _license;
    }
       
    /**
     * @dev Function to check the price for accessing data from a feed.
     * @param _feedId The ID of the data feed.
     * @return The price in wei for accessing the data.
     */
    function checkPrice(uint32 _feedId) public view returns (uint256) {
        (bool status, , uint256 price) = controller.verifyLicense(_feedId, license);
        require(status, 'This feed is not available');
        return price;
    }
    
    /**
     * @dev Function to subscribe to a feed by paying the required subscription fee.
     * @param _address The address of the subscriber.
     * @param _feedId The ID of the data feed.
     */
    function subscribe(address _address, uint32 _feedId) public payable {
        (bool status, , uint256 price) = controller.verifyLicense(_feedId, license);
        require(status && msg.value == price, "Value required. Try the checkPrice(feedId).");
        addSubcriber(_address, _feedId);
    }

    /**
     * @dev Function to get the value of an integer data feed.
     * @param _feedId The ID of the data feed.
     * @return The value of the data feed.
     */
    function getValue(uint32 _feedId) public view returns (int256) {
        IntDataValue memory item = getFeed(_feedId);              
        return item.value;
    }

    /**
     * @dev Function to get the value of an integer data feed.
     * @param _feedId The ID of the data feed.
     * @return _feed is the full version of value with lastupdate and decimal.
     */
    function getFeed(uint32 _feedId) public view returns (IntDataValue memory _feed) {     
        require(isActive(msg.sender, _feedId), 'checkPrice() and subscribe() this service to continue.');  
        ( , address dnAddress, ) = controller.verifyLicense(_feedId, license);
        _feed = IFODataNode(dnAddress).readInt(_feedId);
    }

    /**
     * @dev Function to check if an integer data feed is available.
     * @param _feedId The ID of the data feed.
     * @return A boolean indicating if the data feed is available.
     */
    function isFeedAvailable(uint32 _feedId) public view returns (bool) {
        IntDataValue memory item = getFeed(_feedId);              
        return item.lastUpdate > 0;
    }

    /**
     * @dev Function to get the value of a packed data feed.
     * @param _feedId The ID of the data feed.
     * @return _feed The full value of the datafeed.
     */
    function getPackFeed(uint32 _feedId) public view returns (PackDataValue memory _feed) {   
        require(isActive(msg.sender, _feedId), 'checkPrice() and subscribe() this service to continue.');  
        ( , address dnAddress, ) = controller.verifyLicense(_feedId, license);
        _feed = IFODataNode(dnAddress).readPack(_feedId);
    }

    /**
     * @dev Function to check if a packed data feed is available.
     * @param _feedId The ID of the data feed.
     * @return A boolean indicating if the data feed is available.
     */
    function isPackFeedAvailable(uint32 _feedId) public view returns (bool) {
        PackDataValue memory item = getPackFeed(_feedId);              
        return item.lastUpdate > 0;
    }   
    
    /**
     * @dev Function to verify the signature of an integer data feed.
     * @param _dataFeed The data feed item containing the information to be verified.
     * @return A boolean indicating if the signature is valid.
     */
    function verify(IntDataItem calldata _dataFeed) public view returns (bool) {
        (bool status, , ) = controller.verifyLicense(_dataFeed.feedId, license);
        require(status, 'This Feed is not licensed on this Oracle. Try the subscription');
        return controller.verifySignInt(_dataFeed);
    }

    /**
     * @dev Function to verify the signature of a packed data feed.
     * @param _dataFeed The data feed item containing the information to be verified.
     * @return A boolean indicating if the signature is valid.
     */
    function verifyPack(PackDataItem calldata _dataFeed) public view returns (bool) {        
        (bool status, , ) = controller.verifyLicense(_dataFeed.feedId, license);
        require(status, 'This Feed is not licensed on this Oracle. Try the subscription');
        return controller.verifySignPack(_dataFeed);
    }
}

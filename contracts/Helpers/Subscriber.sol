// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

contract Subscriber {
    // Mapping to store subscription expiration timestamps using a composite key
    // The key is a concatenation of the subscriber's address and the feed ID
    mapping(uint192 => uint256) private subscriberList;    
    
    // Function to add a subscriber with a specified expiration time
    function addSubcriber(address _address, uint32 _feedId) internal {
        // Generate the composite key
        uint192 key = generateKey(_address, _feedId);
        // Set the expiration time to 30 days from the current block timestamp
        subscriberList[key] = block.timestamp + 30 days;
    }

    // Function to generate a composite key from the subscriber's address and feed ID
    function generateKey(address _address, uint32 _feedId) private pure returns (uint192) {
        // Convert the address to uint160
        uint160 addressAsUint = uint160(_address);
        // Concatenate the address and feed ID to create the key
        uint192 concatenatedValue = (uint192(addressAsUint) << 32) | _feedId;
        return concatenatedValue;
    }

    // Function to check if a subscription is active for a given subscriber and feed
    function isActive(address _address, uint32 _feedId) public view returns (bool) {
        // Generate the composite key
        uint192 key = generateKey(_address, _feedId);
        // Get the expiration timestamp from the mapping
        uint256 expires = subscriberList[key];
        // Check if the subscription is active (i.e., expiration timestamp is greater than the current block timestamp)
        return expires > 0 && expires > block.timestamp;
    }
    
    // Function to check the status and remaining days of a subscription
    function checkSubscription(address _address, uint32 _feedId) public view returns (bool, uint256) {
        // Generate the composite key
        uint192 key = generateKey(_address, _feedId);
        // Get the expiration timestamp from the mapping
        uint256 expires = subscriberList[key];
        // If subscription is active, calculate remaining days until expiration
        if (expires > block.timestamp) {
            uint256 expireDays = (expires - block.timestamp) / 1 days;
            return (true, expireDays);
        } else {
            // If subscription is inactive, return false and 0 remaining days
            return (false, 0);
        }
    }
}

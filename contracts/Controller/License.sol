// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "./Manager.sol";

/**
 * @title License
 * @dev This contract manages licenses for data feeds.
 * It inherits from the Manager contract.
 */
contract License is Manager {
    
    mapping(uint40 => uint256) private licenseList;

    /**
     * @dev Constructor function to initialize the License contract.
     * @param _owner The address of the contract owner.
     */
    constructor(address _owner) Manager(_owner) {}

    /**
     * @dev Adds a new license for a data feed.
     * @param _feedId The ID of the data feed.
     * @param _license The type of license (1: free, 2: subscription, 3: pay per use, 4: other).
     * @param _price The price associated with the license.
     */
    function addLicense(uint32 _feedId, uint8 _license, uint256 _price) public onlyOwner {
        uint40 key = generateKey(_feedId, _license);
        licenseList[key] = _price;
    }

    /**
     * @dev Removes a license for a data feed.
     * @param _feedId The ID of the data feed.
     * @param _license The type of license to be removed.
     */
    function dropLicense(uint32 _feedId, uint8 _license) public onlyOwner {
        uint40 key = generateKey(_feedId, _license);
        delete licenseList[key];
    }

    /**
     * @dev Verifies the license for a given data feed.
     * @param _feedId The ID of the data feed.
     * @param _license The type of license to be verified.
     * @return A tuple containing a boolean indicating if the license exists, the address of the data node providing the feed, and the price associated with the license.
     */
    function verifyLicense(uint32 _feedId, uint8 _license) public view returns (bool, address, uint256) {
        uint40 key = generateKey(_feedId, _license);
        uint256 price = licenseList[key];
        if (price == 0) return (false, address(0), 0);
        return (true, getDataNodeFeed(_feedId), price);
    }

    /**
     * @dev Generates a unique key for a license based on the feed ID and license type.
     * @param _uint32Value The feed ID.
     * @param _uint8Value The license type.
     * @return The unique key for the license.
     */
    function generateKey(uint32 _uint32Value, uint8 _uint8Value) private pure returns (uint40) {
        uint40 key = (uint40(_uint32Value) << 8) | _uint8Value;
        return key;
    }
}

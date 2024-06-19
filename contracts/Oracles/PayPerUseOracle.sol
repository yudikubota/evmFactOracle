// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

// Importing Control contract for access control
import "../Helpers/Control.sol";
// Importing DataNodeInterface for interacting with data nodes
import "../Helpers/DataNodeInterface.sol";
// Importing ReentrancyGuard for preventing reentrancy attacks
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title PayPerUseOracle
 * @dev Contract for accessing data from licensed feeds with pay-per-use model.
 */
contract PayPerUseOracle is Control, ReentrancyGuard {
    
    uint8 private license; // License type required for accessing data
    
    /**
     * @dev Constructor to initialize the PayPerUseOracle contract with a controller address and license type.
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
     * @dev Function to get the value of an integer data feed.
     * @param _feedId The ID of the data feed.
     */
    function getValue(uint32 _feedId) public payable {
        // Charge user and get data node address
        address dnAddress = chargeAddress(_feedId);
        require(dnAddress > address(0), 'Not available');
        // Read integer data from the data node and invoke callback function in the caller contract
        IntDataValue memory _feed = IFODataNode(dnAddress).readInt(_feedId);
        callbackInterface(msg.sender).OracleCallback(_feedId, _feed.value);    
    }

    /**
     * @dev Function to get the value of a packed data feed.
     * @param _feedId The ID of the data feed.
     */
    function getPackValue(uint32 _feedId) public payable {
        // Charge user and get data node address
        address dnAddress = chargeAddress(_feedId);
        require(dnAddress > address(0), 'Not available');
        // Read packed data from the data node and invoke callback function in the caller contract
        PackDataValue memory _feed = IFODataNode(dnAddress).readPack(_feedId);
        callbackInterface(msg.sender).OracleCallbackPack(_feedId, _feed.value);    
    }

    /**
     * @dev Function to request data from a feed.
     * @param _feedId The ID of the data feed.
     */
    function request(uint32 _feedId) public payable {
        // Charge user and get data node address
        address dnAddress = chargeAddress(_feedId);
        require(dnAddress != address(0), 'Try getIntValue() or getPackValue()');                 
        emit Request(_feedId, msg.sender);
    }

    /**
     * @dev Function for a manager to respond with data for an integer feed.     * 
     * @param _feedId The ID of the data feed.
     * @param _contractAddress The address of the contract requesting the data.
     * @param _value The value to be sent as a response.
     * @notice GasStipped is controlled by the msg.sender.
     */
    function response(uint32 _feedId, address _contractAddress, int256 _value) public {
        require(controller.isManager(msg.sender), 'You are not allowed to reply.');
        callbackInterface(_contractAddress).OracleCallback(_feedId, _value);    
    }

    /**
     * @dev Function for a manager to respond with data for a packed feed.
     * @param _feedId The ID of the data feed.
     * @param _contractAddress The address of the contract requesting the data.
     * @param _value The value to be sent as a response.
     */
    function responsePack(uint32 _feedId, address _contractAddress, bytes calldata _value) public {
        require(controller.isManager(msg.sender), 'You are not allowed to reply.');
        callbackInterface(_contractAddress).OracleCallbackPack(_feedId, _value);    
    }

    /**
     * @dev Function to verify the signature of an integer data feed.
     * @param _dataFeed The data feed item containing the information to be verified.
     */
    function verify(IntDataItem calldata _dataFeed) public payable {
        // Charge user and verify signature
        chargeAddress(_dataFeed.feedId);        
        if (controller.verifySignInt(_dataFeed)) {
            // If signature is valid, invoke callback function in the caller contract
            callbackInterface(msg.sender).OracleCallback(_dataFeed.feedId, _dataFeed.value);    
        }
    }

    /**
     * @dev Function to verify the signature of a packed data feed.
     * @param _dataFeed The data feed item containing the information to be verified.
     */
    function verifyPack(PackDataItem calldata _dataFeed) public payable {        
        // Charge user and verify signature
        chargeAddress(_dataFeed.feedId);        
        if (controller.verifySignPack(_dataFeed)) {
            // If signature is valid, invoke callback function in the caller contract
            callbackInterface(msg.sender).OracleCallbackPack(_dataFeed.feedId, _dataFeed.value);    
        }
    }

    /**
     * @dev Function to charge the user and retrieve the data node address for a feed.
     * @param _feedId The ID of the data feed.
     * @return The address of the data node.
     */
    function chargeAddress(uint32 _feedId) private nonReentrant returns (address) {
        // Check if caller is a contract
        require(msg.sender.code.length > 0, "Function call to a non-contract account");
        // Verify license and retrieve data node address and price
        (bool status, address dnAddress, uint256 price) = controller.verifyLicense(_feedId, license);
        require(status, 'This Feed is not allowed here. Try the Subscription Oracle');
        // Ensure user sent enough funds to access data
        require(msg.value >= price, 'Insufficient value. checkPrice()');        
        return dnAddress;
    }

    /**
     * @dev Event emitted when a request for data is made.
     * @param feedId The ID of the data feed.
     * @param contractAddress The address of the contract making the request.
     */
    event Request(uint32 feedId, address contractAddress);
}

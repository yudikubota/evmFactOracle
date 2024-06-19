// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "./DataTypes.sol";

interface IFOController {
    function isManager(address _address) external view returns (bool);    
    function isOracle(address _address) external view returns (bool);        
    function verifySignInt(IntDataItem  calldata _dataItem) external view returns (bool);
    function verifySignPack(PackDataItem calldata _dataItem) external view returns (bool);
    function verifyLicense(uint32 _feedId, uint8 _license) external view returns (bool, address, uint256);
    function getDataNodeFeed(uint32 _feedId) external view returns (address);
    function verifyHash(uint32 _feedId,bytes32 _orgMsg, bytes calldata _msgHash) external view returns (bool);
}

interface callbackInterface {
    function OracleCallback(uint32 _feedId, int256 _value) external;
    function OracleCallbackPack(uint32 _feedId, bytes calldata _value) external;
}    


/**
 * @title Control
 * @dev This contract provides control functionalities for interacting with the oracle system.
 */
contract Control {

    IFOController controller;

    /**
     * @dev Constructor function to initialize the Control contract.
     * @param _address The address of the IFOController contract.
     */
    constructor(address _address) {
        controller = IFOController(_address);
    }

    /**
     * @dev Changes the controller address.
     * @param _address The address of the new controller.
     */
    function changeController(address _address) public {
        require(controller.isManager(_address), 'Operation not allowed.');
        controller = IFOController(_address);
    }

    /**
     * @dev Allows the contract to withdraw funds.
     */
    function withdraw() public {
        require(controller.isManager(msg.sender), 'Operation not allowed.');
        payable(msg.sender).transfer(address(this).balance);
    }
}


    


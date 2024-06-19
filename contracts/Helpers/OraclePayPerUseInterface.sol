// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "./DataTypes.sol";

interface IFPPUOracle {
    function checkPrice(uint32 _feedId) external view returns (uint256);
    function getValue (uint32 _feedId ) external payable ;    
    function getPackValue (uint32 _feedId ) external payable;
    function request(uint32 _feedId ) external  payable;
    function verify(IntDataItem calldata _dataFeed) external payable;
    function verifyPack(PackDataItem calldata _dataFeed) external payable;    
}





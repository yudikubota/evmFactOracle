// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "./DataTypes.sol";

interface IFODataNode {
    function store(PackDataItem calldata _dataFeed) external;
    function store(IntDataItem calldata _dataFeed) external;   
    function readInt(uint32 _feedId) external view returns (IntDataValue memory);
    function readPack(uint32 _feedId) external view returns (PackDataValue memory);
}





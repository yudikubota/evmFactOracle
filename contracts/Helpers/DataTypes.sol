// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

// Struct representing a data value for an integer data feed
struct IntDataValue {
    uint256 lastUpdate; // Timestamp of the last update
    int256 value;       // Integer value
    int256 decimal;     // Decimal value (if applicable)
}

// Struct representing a data item for an integer data feed
struct IntDataItem {
    uint32 feedId;      // ID of the data feed
    uint32 signerId;    // ID of the signer
    uint256 lastUpdate; // Timestamp of the last update
    int256 value;       // Integer value
    int256 decimal;     // Decimal value (if applicable)
    bytes msgHash;      // Message hash
}

// Struct representing a data value for a packed data feed
struct PackDataValue {
    uint256 lastUpdate; // Timestamp of the last update
    bytes value;        // Packed data value
    int256 decimal;     // Decimal value (if applicable)
}

// Struct representing a data item for a packed data feed
struct PackDataItem {
    uint32 feedId;      // ID of the data feed
    uint32 signerId;    // ID of the signer
    uint256 lastUpdate; // Timestamp of the last update
    bytes value;        // Packed data value
    int256 decimal;     // Decimal value (if applicable)
    bytes msgHash;      // Message hash
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../Helpers/OraclePayPerUseInterface.sol";
import "../Helpers/DataTypes.sol";



contract ConsumerPPU {
    address oracleAddress;
    uint32 public feedId;
    int256 public value;
    bytes public  valuePack;

    IFPPUOracle oracle;
    

    constructor(address _address) {
        oracleAddress=_address;
        oracle = IFPPUOracle(oracleAddress);
    }
    
    function get(uint32 _feedId) public payable {
        oracle.getValue{value: msg.value}(_feedId);
    }

    function getPack(uint32 _feedId) public payable {
        oracle.getPackValue{value: msg.value}(_feedId);
    }


    function verify(IntDataItem calldata _dataFeed) public payable {
        oracle.verify{value: msg.value}(_dataFeed);
    }

    function verifyPack(PackDataItem calldata _dataFeed) public payable {
        oracle.verifyPack{value: msg.value}(_dataFeed);
    }
    

    function OracleCallback(uint32 _feedId, int256 _value) public onlyOracle {
        feedId=_feedId;
        value=_value;
    }


    function OracleCallbackPack(uint32 _feedId, bytes calldata _value) public onlyOracle {
        feedId=_feedId;
        valuePack=_value;
    }


    function request(uint32 _feedId) public payable {
        oracle.request{value: msg.value}(_feedId);
    }


    function reset() public {
        value=0;
        valuePack=bytes("");
    }

    modifier onlyOracle() {
        require(msg.sender==oracleAddress);
        _;
    }
}
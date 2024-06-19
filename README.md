# Fact Finance Oracle 

At Fact Finance, we're reshaping web3 infrastructure with tailored, reliable real-world data. By forging strategic partnerships with official data providers, including research institutes, sports leagues, and governmental data agencies, we empower businesses to confidently navigate regional nuances. Our commitment to education and sustainability ensures a lasting impact and growth, driving tangible progress in the digital landscape. Join us in revolutionizing web3’s future—one data point at a time.

[Read more about the project](https://respected-yard-256.notion.site/About-Fact-Finance-c2c2a72cdc914fd4b3094d71fe045437)

## Repository Structure 

This repository provides a comprehensive set of smart contracts for Fact Finance Oracle protocol. The repository is divided into several modules: controller, oracle, auditor, store, and helpers. Each module serves a specific purpose in the overall system.

1. Controller: Manages access control and roles.
2. Oracle: Includes different oracle contracts for accessing data feeds.
3. Auditor: Contains contracts for auditing and verifying data.
4. Store: Manages data storage and retrieval.
5. Helpers: Provides utility contracts and data structures.

## Overview of Contracts

### Controller

The `Controller` module manages roles and permissions within the system.

#### Contracts:

. `FOController`: Main controller contract inheriting from Signer.

### Oracle

The `Oracle` module includes various oracle contracts for accessing and verifying data feeds.   

    . `PayPerUseOracle`: Access data feeds on a pay-per-use basis.
    . `OpenOracle`: Open access to licensed data feeds.
    . `SubscriptionOracle`: Subscribe to data feeds and access them for a period of time.


### Auditor

The `Auditor` module contains contracts for auditing and verifying the integrity of data.

    . `AuditorContract`: Example of set and check limits.

### Store

The `Store` module manages the storage and retrieval of data within the system.


    . `FODataNode`: Stores and retrieves data values.

### Helpers

The `Helpers` module provides utility contracts and data structures used throughout the system.

    . `Control`: Manages controller interactions.
    . `DataTypes`: Defines data structures used by the system.
    . `Subscriber`: Manages subscription logic.

## Contract Documentation

### PayPerUseOracle
The PayPerUseOracle contract allows users to access data feeds on a pay-per-use basis. It includes functions to check feed prices, request data, and verify signatures.

Example Usage:

```solidity

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./DataTypes.sol";
import "./OraclePayPerUseInterface.sol";

contract ConsumerPPU {
    address oracleAddress;
    uint32 public feedId;
    int256 public value;

    constructor(address _address) {
        oracleAddress = _address;
        oracle = IFPPUOracle(oracleAddress);
    }

    function verify(IntDataItem calldata _dataFeed) public payable {
        oracle.verify{value: msg.value}(_dataFeed);
    }

    function verifyPack(PackDataItem calldata _dataFeed) public payable {
        oracle.verifyPack{value: msg.value}(_dataFeed);
    }

    function OracleCallback(uint32 _feedId, int256 _value) public onlyOracle {
        feedId = _feedId;
        value = _value;
    }

    function OracleCallbackPack(uint32 _feedId, bytes calldata _value) public onlyOracle {
        feedId = _feedId;
        valuePack = _value;
    }

    modifier onlyOracle() {
        require(msg.sender == oracleAddress);
        _;
    }
}
```

## OpenOracle
The `OpenOracle` contract provides open access to licensed data feeds. Users can check the availability of feeds and retrieve their values.

## SubscriptionOracle
The `SubscriptionOracle` contract allows users to subscribe to data feeds and access them for a specified period. It includes functions to subscribe, check subscription status, and retrieve feed values.

## Setup and Deployment

1. Clone the repository: git clone https://github.com/your-repo/oracle-integration.git
2. Navigate to the project directory: cd oracle-integration
3. Install dependencies: npm install
4. Compile contracts: npx hardhat compile
5. Deploy contracts: npx hardhat run scripts/deploy.js


## Testing

To run tests, use the following command:

```bash

npx hardhat test

```


## Deploy

To run deploy local, use the following command:

```bash
 
npx hardhat node  # terminal 1

npx hardhat run scripts/deploy.ts --network hardhat

# Expected result
# Controller deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
# DataNode deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
# OpenOracle deployed to: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
# SubscriptionOracle deployed to: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
# PayPerUseOracle deployed to: 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
# Deployment and setup complete.

```

## Dappi Integration
You can use the three Oracles to request a feed verification returned from https://api.fact.finance.

### Example Integration with PayPerUseOracle

```solidity

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./DataTypes.sol";
import "./OraclePayPerUseInterface.sol";

contract ConsumerPPU {
    address oracleAddress;
    uint32 public feedId;
    int256 public value;

    constructor(address _address) {
        oracleAddress = _address;
        oracle = IFPPUOracle(oracleAddress);
    }

    function verify(IntDataItem calldata _dataFeed) public payable {
        oracle.verify{value: msg.value}(_dataFeed);
    }

    function verifyPack(PackDataItem calldata _dataFeed) public payable {
        oracle.verifyPack{value: msg.value}(_dataFeed);
    }

    function OracleCallback(uint32 _feedId, int256 _value) public onlyOracle {
        feedId = _feedId;
        value = _value;
    }

    function OracleCallbackPack(uint32 _feedId, bytes calldata _value) public onlyOracle {
        feedId = _feedId;
        valuePack = _value;
    }

    modifier onlyOracle() {
        require(msg.sender == oracleAddress);
        _;
    }
}
```

Feel free to customize the documentation further to fit your specific use case or requirements.

## License

This project is licensed under the Apache License 2.0. See the LICENSE file for more details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## Contact

For any questions or support, please contact us at support@fact.finance









ChatGPT pode cometer erros. Considere verificar informações importantes.

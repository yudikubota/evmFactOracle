Oracle Query Contracts Documentation
Introduction
These oracle query contracts provide interfaces to access various data feeds stored on the blockchain. The contracts facilitate querying data by different license types and subscription models.

PayPerUseOracle
Description
PayPerUseOracle allows users to query data feeds by paying a fee per usage. Users can request data by calling functions and providing the required parameters along with payment.

Interface


contract PayPerUseOracle {
    function checkPrice(uint32 _feedId) public view returns (uint256);
    function getValue(uint32 _feedId) public payable;
    function getPackValue(uint32 _feedId) public payable;
    function request(uint32 _feedId) public payable;
    function response(uint32 _feedId, address _contractAddress, int256 _value) public;
    function responsePack(uint32 _feedId, address _contractAddress, bytes calldata _value) public;
    function verify(IntDataItem calldata _dataFeed) public payable;
    function verifyPack(PackDataItem calldata _dataFeed) public payable;
}
Example Usage


// Example usage of PayPerUseOracle contract
contract ExamplePayPerUse {
    PayPerUseOracle public oracle;

    constructor(address _oracleAddress) {
        oracle = PayPerUseOracle(_oracleAddress);
    }

    function queryData(uint32 _feedId) external payable {
        // Check the price for querying data
        uint256 price = oracle.checkPrice(_feedId);

        // Make payment
        require(msg.value >= price, "Insufficient payment");
        
        // Get data
        oracle.getValue{value: price}(_feedId);
    }
}


OpenOracle
Description
OpenOracle allows users to query data feeds without requiring a subscription. Users can access data feeds by calling functions directly.

Interface

contract OpenOracle {
    function isFeedAvailable(uint32 _feedId) public view returns (bool);
    function getValue(uint32 _feedId) public view returns (int256);
    function getFeed(uint32 _feedId) public view returns (IntDataValue memory);
    function isPackFeedAvailable(uint32 _feedId) public view returns (bool);
    function getPackFeed(uint32 _feedId) public view returns (PackDataValue memory);
    function verify(IntDataItem calldata _dataFeed) public view returns (bool);
    function verifyPack(PackDataItem calldata _dataFeed) public view returns (bool);
}
Example Usage


// Example usage of OpenOracle contract
contract ExampleOpenOracle {
    OpenOracle public oracle;

    constructor(address _oracleAddress) {
        oracle = OpenOracle(_oracleAddress);
    }

    function queryData(uint32 _feedId) external view {
        // Check if feed is available
        require(oracle.isFeedAvailable(_feedId), "Feed not available");
        
        // Get data
        int256 data = oracle.getValue(_feedId);
        // Process data...
    }
}
SubscriptionOracle
Description
SubscriptionOracle allows users to subscribe to data feeds by paying a subscription fee. Subscribers gain access to data feeds for a specified period after subscribing.

Interface


contract SubscriptionOracle {
    function checkPrice(uint32 _feedId) public view returns (uint256);
    function subscribe(address _address, uint32 _feedId) public payable;
    function getValue(uint32 _feedId) public view returns (int256);
    function getFeed(uint32 _feedId) public view returns (IntDataValue memory);
    function isFeedAvailable(uint32 _feedId) public view returns (bool);
    function getPackFeed(uint32 _feedId) public view returns (PackDataValue memory);
    function isPackFeedAvailable(uint32 _feedId) public view returns (bool);
    function verify(IntDataItem calldata _dataFeed) public view returns (bool);
    function verifyPack(PackDataItem calldata _dataFeed) public view returns (bool);
}
Example Usage

// Example usage of SubscriptionOracle contract
contract ExampleSubscriptionOracle {
    SubscriptionOracle public oracle;

    constructor(address _oracleAddress) {
        oracle = SubscriptionOracle(_oracleAddress);
    }

    function subscribeAndGetFeed(uint32 _feedId) external payable {
        // Check the subscription price
        uint256 price = oracle.checkPrice(_feedId);

        // Make payment
        require(msg.value == price, "Incorrect payment amount");

        // Subscribe
        oracle.subscribe{value: price}(msg.sender, _feedId);

        // Get feed data
        IntDataValue memory data = oracle.getFeed(_feedId);
        // Process data...
    }
}
Feel free to customize the documentation further to fit your specific use case or requirements.
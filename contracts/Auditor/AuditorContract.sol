// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/access/Ownable.sol";

contract AuditorContract is Ownable {

    struct limitRange {
        int256 min;
        int256 max;
    }

    mapping(uint32 => limitRange) public limitList;

    constructor(address _owner) Ownable(_owner) {}

    function setLimits(uint32 _feedId, int256 _min, int256 _max) public onlyOwner {
        limitRange memory limit = limitRange(_min,_max);   
        limitList[_feedId] = limit;
    }

    function checkValue(uint32 _feedId, int256 _value) public view  returns (bool) {
        limitRange memory limit = limitList[_feedId];
        if (limit.min == 0 && limit.max == 0) return true;

        if (_value < limit.min || _value > limit.max) return false;
        
        return true;
    }
}
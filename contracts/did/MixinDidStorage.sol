pragma solidity ^0.6.0;

import "../libs/IterableMap.sol";


contract MixinDidStorage {
    using IterableMapping for IterableMapping.itmap;
    mapping(string => IterableMapping.itmap) public data;

}
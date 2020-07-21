pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;


import "./iterable_map.sol";

contract Data {
    using IterableMapping for IterableMapping.itmap;
    mapping(string => IterableMapping.itmap) public data;
}
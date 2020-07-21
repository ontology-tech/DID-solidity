pragma solidity ^0.5.9;
import "../libs/IterableMap.sol";


contract MixinDidStorage {
    
  mapping(string => IterableMapping.itmap) public data;

}
pragma solidity ^0.6.0;
import "../libs/IterableMap.sol";


contract MixinDidStorage {
    
  mapping(string => IterableMapping.itmap) public data;

}
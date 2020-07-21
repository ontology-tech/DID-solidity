pragma solidity ^0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "../libs/DidUtils.sol";
import "../interface/IDid.sol";
import "./MixinDidStorage.sol";

contract MixinIDid is MixinDidStorage, IDid {
    // Do not hold any state variables in this contract

}
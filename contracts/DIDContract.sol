pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./ContentContract.sol";
contract DIDContract {
    mapping(string => ContentContract) public contents;
}
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./ContentContract.sol";

abstract contract DIDContract {
    event Register(string indexed did);
    event Revoke(string indexed did);
}
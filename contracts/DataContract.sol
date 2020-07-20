pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

abstract contract DataContract {
    function put(bytes memory key, bytes memory value) public virtual;
    function get(bytes memory key) public virtual;
}
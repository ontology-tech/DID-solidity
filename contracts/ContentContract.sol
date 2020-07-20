pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./DataContract.sol";
abstract contract ContentContract {
    mapping(string => DataContract) didData;

    function put(string memory did, bytes memory data) public virtual;
    function remove(string memory did, uint index) public virtual;
    function update(string memory did, uint index, bytes memory data) public virtual;
    function get(string memory did, uint inde) public virtual returns(bytes memory);
}
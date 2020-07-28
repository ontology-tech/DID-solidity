// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./BytesUtils.sol";

library KeyUtils {

    // status represent DID activated("1") or revoked("0")
    function genStatusKey(string memory did) public pure returns (string memory){
        return string(abi.encodePacked(BytesUtils.toLower(did), bytes("status")));
    }

    function genStatusSecondKey() public pure returns (bytes32){
        return keccak256(bytes("status"));
    }

    function genContextKey(string memory did) public pure returns (string memory){
        return string(abi.encodePacked(BytesUtils.toLower(did), bytes("@context")));
    }

    function genContextSecondKey(string memory ctx) public pure returns (bytes32){
        return keccak256(bytes(ctx));
    }

    function genPubKeyListKey(string memory did) public pure returns (string memory){
        return string(abi.encodePacked(BytesUtils.toLower(did), bytes("publicKey")));
    }

    function genPubKeyListSecondKey(bytes memory pubKey) public pure returns (bytes32){
        return keccak256(pubKey);
    }

    function genAuthOrderKey(string memory did) public pure returns (string memory){
        return string(abi.encodePacked(BytesUtils.toLower(did), bytes("authOrder")));
    }

    /**
    * @dev auth order store authentication key order, hash(pubKey) => pubKey,
    *   because authentication list must be orderly, so there is a field to record this order
    */
    function genAuthOrderSecondKey(bytes memory pubKey) public pure returns (bytes32){
        return keccak256(pubKey);
    }

    function genControllerKey(string memory did) internal pure returns (string memory) {
        return string(abi.encodePacked(BytesUtils.toLower(did), "controller"));
    }

    function genControllerSecondKey(string memory controller) public pure returns (bytes32){
        return keccak256(bytes(controller));
    }

    function genServiceKey(string memory did) internal pure returns (string memory) {
        return string(abi.encodePacked(BytesUtils.toLower(did), "service"));
    }

    function genServiceSecondKey(string memory serviceId) internal pure returns (bytes32) {
        return keccak256(bytes(serviceId));
    }

    function genCreateTimeKey(string memory did) internal pure returns (string memory) {
        return string(abi.encodePacked(BytesUtils.toLower(did), "createTime"));
    }

    function genCreateTimeSecondKey() internal pure returns (bytes32) {
        return keccak256("createTime");
    }

    function genUpdateTimeKey(string memory did) internal pure returns (string memory) {
        return string(abi.encodePacked(BytesUtils.toLower(did), "updateTime"));
    }

    function genUpdateTimeSecondKey() internal pure returns (bytes32) {
        return keccak256("updateTime");
    }
}
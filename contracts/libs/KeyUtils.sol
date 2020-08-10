// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./BytesUtils.sol";

library KeyUtils {

    function genContextKey(string memory did) public pure returns (string memory){
        did = BytesUtils.toLower(did);
        return string(abi.encodePacked(did, "@context"));
    }

    function genContextSecondKey(string memory ctx) public pure returns (bytes32){
        return keccak256(bytes(ctx));
    }

    function genPubKeyListKey(string memory did) public pure returns (string memory){
        did = BytesUtils.toLower(did);
        return string(abi.encodePacked(did, "publicKey"));
    }

    function genPubKeyListSecondKey(bytes memory pubKey) public pure returns (bytes32){
        return keccak256(pubKey);
    }

    function genControllerKey(string memory did) public pure returns (string memory) {
        did = BytesUtils.toLower(did);
        return string(abi.encodePacked(did, "controller"));
    }

    function genControllerSecondKey(string memory controller) public pure returns (bytes32){
        return keccak256(bytes(controller));
    }

    function genServiceKey(string memory did) public pure returns (string memory) {
        did = BytesUtils.toLower(did);
        return string(abi.encodePacked(did, "service"));
    }

    function genServiceSecondKey(string memory serviceId) public pure returns (bytes32) {
        return keccak256(bytes(serviceId));
    }

    function genCreateTimeKey(string memory did) public pure returns (string memory) {
        did = BytesUtils.toLower(did);
        return string(abi.encodePacked(did, "createTime"));
    }

    function genCreateTimeSecondKey() public pure returns (bytes32) {
        // return keccak256("createTime");
        return 0x0ec4c19546057c37b4587fd3965245ae45dc2424ac1b5ef165832a224051b594;
    }

    function genUpdateTimeKey(string memory did) public pure returns (string memory) {
        did = BytesUtils.toLower(did);
        return string(abi.encodePacked(did, "updateTime"));
    }

    function genUpdateTimeSecondKey() public pure returns (bytes32) {
        // return keccak256("updateTime");
        return 0xc82895c0c3ceabd782a01504a94c9aacea049cda0758a362503092064cb5015f;
    }
}
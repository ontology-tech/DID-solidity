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
        // return keccak256("status");
        return 0xcd423760c9650eb549b1615f6cf96d420e32aadcea2ff5fe11c26457244adcc1;
    }

    function genContextKey(string memory did) public pure returns (string memory){
        return string(abi.encodePacked(BytesUtils.toLower(did), "@context"));
    }

    function genContextSecondKey(string memory ctx) public pure returns (bytes32){
        return keccak256(bytes(ctx));
    }

    function genPubKeyListKey(string memory did) public pure returns (string memory){
        return string(abi.encodePacked(BytesUtils.toLower(did), "publicKey"));
    }

    function genPubKeyListSecondKey(bytes memory pubKey) public pure returns (bytes32){
        return keccak256(pubKey);
    }

    function genAuthOrderKey(string memory did) public pure returns (string memory){
        return string(abi.encodePacked(BytesUtils.toLower(did), "authOrder"));
    }

    /**
    * @dev auth order store authentication key order, hash(pubKey) => pubKey,
    *   because authentication list must be orderly, so there is a field to record this order
    */
    function genAuthOrderSecondKey(bytes memory pubKey) public pure returns (bytes32){
        return keccak256(pubKey);
    }

    function genControllerKey(string memory did) public pure returns (string memory) {
        return string(abi.encodePacked(BytesUtils.toLower(did), "controller"));
    }

    function genControllerSecondKey(string memory controller) public pure returns (bytes32){
        return keccak256(bytes(controller));
    }

    function genServiceKey(string memory did) public pure returns (string memory) {
        return string(abi.encodePacked(BytesUtils.toLower(did), "service"));
    }

    function genServiceSecondKey(string memory serviceId) public pure returns (bytes32) {
        return keccak256(bytes(serviceId));
    }

    function genCreateTimeKey(string memory did) public pure returns (string memory) {
        return string(abi.encodePacked(BytesUtils.toLower(did), "createTime"));
    }

    function genCreateTimeSecondKey() public pure returns (bytes32) {
        // return keccak256("createTime");
        return 0x0ec4c19546057c37b4587fd3965245ae45dc2424ac1b5ef165832a224051b594;
    }

    function genUpdateTimeKey(string memory did) public pure returns (string memory) {
        return string(abi.encodePacked(BytesUtils.toLower(did), "updateTime"));
    }

    function genUpdateTimeSecondKey() public pure returns (bytes32) {
        // return keccak256("updateTime");
        return 0xc82895c0c3ceabd782a01504a94c9aacea049cda0758a362503092064cb5015f;
    }
}
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

library KeyUtils {

    // status represent DID activated("1") or revoked("0")
    function genStatusKey(string memory did) public pure returns (string memory){
        return string(abi.encodePacked(did, bytes("status")));
    }

    function genStatusSecondKey() public pure returns (bytes32){
        return keccak256(bytes("status"));
    }

    function genContextKey(string memory did) public pure returns (string memory){
        return string(abi.encodePacked(did, bytes("@context")));
    }

    function genContextSecondKey(string memory ctx) public pure returns (bytes32){
        return keccak256(bytes(ctx));
    }

    function genPubKeyListKey(string memory did) public pure returns (string memory){
        return string(abi.encodePacked(did, bytes("publicKey")));
    }

    function genPubKeyListSecondKey(bytes memory pubKey) public pure returns (bytes32){
        return keccak256(pubKey);
    }

    function genControllerKey(string memory did) internal pure returns (string memory) {
        return string(abi.encodePacked(did, "controller"));
    }

    function genControllerSecondKey(string memory controller) public pure returns (bytes32){
        return keccak256(bytes(controller));
    }

    function genServiceKey(string memory did) internal pure returns (string memory) {
        return string(abi.encodePacked(did, "service"));
    }

    function genServiceSecondKey(string memory did, string memory serviceId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(did, serviceId));
    }

    function genCreateTimeKey(string memory did) internal pure returns (string memory) {
        return string(abi.encodePacked(did, "createTime"));
    }

    function genCreateTimeSecondKey() internal pure returns (bytes32) {
        return keccak256("createTime");
    }

    function genUpdateTimeKey(string memory did) internal pure returns (string memory) {
        return string(abi.encodePacked(did, "updateTime"));
    }

    function genUpdateTimeSecondKey() internal pure returns (bytes32) {
        return keccak256("updateTime");
    }
}
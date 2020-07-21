pragma solidity ^0.6.0;

import "./BytesUtils.sol";

library DidUtils {
    function verifyId(bytes memory id) internal pure returns (bool) {
        // TODO: check if Id length requirement is mandatory
        require(id.length >= 9, "Id length is too short");
        // Check the first prefix is correct
        require(BytesUtils.equal(BytesUtils.slice(id, 0, 9), "did:near:"), "Id prefix is not did:near:");
        // TODO: base58 bitcoin encoding.Decode()
        // Verify Id
        return true;
    }

    function verifyDIDSignature(bytes memory pubkey) public view returns (bool){
        address addr = pubKeyToAddr(pubkey);
        return addr == msg.sender;
    }

    function addressFromPubKey(bytes memory publicKey) internal pure returns (address) {
        return address(uint160(bytes20(keccak256(publicKey))));
    }

    function genContextKey(string memory did) public view returns (bytes32){
        return keccak256(abi.encodePacked(did, "@context"));
    }

    function genPubKeyListKey(string memory did) public view returns (bytes32){
        return keccak256(abi.encodePacked(did, "publicKey"));
    }

    function updateTime() internal pure returns (bool) {
        return true;
    }

}
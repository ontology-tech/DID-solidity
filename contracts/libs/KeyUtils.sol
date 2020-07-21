pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

library KeyUtils {

    function genIdKey(string memory did) public view returns (string memory){
        return string(abi.encodePacked(did, bytes("id")));
    }

    // document.id is single value
    function genIdSencondKey() public view returns (bytes32){
        return keccak256(bytes("id"));
    }

    function genContextKey(string memory did) public view returns (string memory){
        return string(abi.encodePacked(did, bytes("@context")));
    }

    function genContextSecondKey(string memory ctx) public view returns (bytes32){
        return keccak256(bytes(ctx));
    }

    function genPubKeyListKey(string memory did) public view returns (string memory){
        return string(abi.encodePacked(did, bytes("publicKey")));
    }

    function genPubKeyListSecondKey(string memory pubKeyId) public view returns (bytes32){
        return keccak256(bytes(pubKeyId));
    }

    function genAuthListKey(string memory did) public view returns (string memory){
        return string(abi.encodePacked(did, bytes("authentication")));
    }

    function genAuthListSecondKey(string memory pubKeyId) public view returns (bytes32){
        return keccak256(bytes(pubKeyId));
    }
}
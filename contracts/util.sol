pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

library Utils {

    function genContextKey(string memory did) public view returns (bytes32){
        return keccak256(abi.encodePacked(did, "@context"));
    }

    function genPubKeyListKey(string memory did) public view returns (bytes32){
        return keccak256(abi.encodePacked(did, "publicKey"));
    }


    function verifyDID(string memory did) public view returns (bool){
        // todo:
        return true;
    }

    function pubKeyToAddr(bytes memory pubkey) public view returns (address){
        return address(uint(keccak256(pubkey)));
    }

    function verifyDIDSignature(bytes memory pubkey) public view returns (bool){
        address addr = pubKeyToAddr(pubkey);
        return addr == msg.sender;
    }


}
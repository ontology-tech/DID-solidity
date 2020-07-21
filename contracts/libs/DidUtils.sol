pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

library DidUtils {

    function verifyDIDFormat(string memory did) public view returns (bool){
        // todo:
        return true;
    }

    function pubKeyToAddr(bytes memory pubkey) public view returns (address){
        return address(uint(keccak256(pubkey)));
    }

    function verifyPubKeySignature(bytes memory pubkey) public view returns (bool){
        address addr = pubKeyToAddr(pubkey);
        return addr == msg.sender;
    }

}
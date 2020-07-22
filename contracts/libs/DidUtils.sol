pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;
import "./BytesUtils.sol";

library DidUtils {

    function verifyDIDFormat(string memory did) public pure returns (bool){
        // verify did prefix
        bytes memory didBytes = bytes(did);
        require(didBytes.length == 98, "did length is illegal");
        bytes memory prefix = BytesUtils.slice(didBytes, 0, 19);
        require(BytesUtils.equal(prefix, bytes("did:near:")), "did's prefix is invalid");
        return true;
    }

    function pubKeyToAddr(bytes memory pubkey) public pure returns (address){
        return address(uint(keccak256(pubkey)));
    }

    function verifyPubKeySignature(bytes memory pubkey) public view returns (bool){
        address addr = pubKeyToAddr(pubkey);
        return addr == msg.sender;
    }

}
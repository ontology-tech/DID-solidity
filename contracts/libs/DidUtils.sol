pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

library DidUtils {

    function verifyDIDFormat(string memory did) public pure returns (bool){
        // todo:
        return true;
    }

    function pubKeyToAddr(bytes memory pubkey) public pure returns (address){
        return address(uint(keccak256(pubkey)));
    }
}
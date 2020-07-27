pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./BytesUtils.sol";

library DidUtils {

    // example: did:celo:0x5Ee76017be7F983a520a778B413758A9DB49cBe9, did:celo:5Ee76017be7F983a520a778B413758A9DB49cBe9
    function verifyDIDFormat(string memory did) public pure returns (bool){
        bytes memory didData = bytes(did);
        if (didData.length < 49) {
            return false;
        }
        bytes memory prefix = bytes("did:celo:");
        if (!BytesUtils.equal(BytesUtils.slice(didData, 0, prefix.length), prefix)) {
            return false;
        }
        bytes memory addressBytesData = BytesUtils.slice(didData, prefix.length, didData.length - prefix.length);
        bytes memory addressBytes = BytesUtils.fromHex(string(addressBytesData));
        return addressBytes.length == 20;
    }

    function pubKeyToAddr(bytes memory pubkey) public pure returns (address){
        return address(uint(keccak256(pubkey)));
    }
}
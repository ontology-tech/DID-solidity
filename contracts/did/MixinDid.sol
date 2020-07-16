pragma solidity ^0.6.0;
// TODO: check and ensure if this is definitely safe to use
pragma experimental ABIEncoderV2;

import "./../libs/DidUtils.sol";

contract MixinIDid {
    // Do not hold any state variables in this contract
    mapping(bytes => bool) public DidExist;
    mapping(bytes => uint) public DidCreatedTime;

    mapping(bytes => PublicKey[]) public PublicKeyByIdByKey;



    struct PublicKey {
        bytes key;
        bool revoked;
        bytes controller;
        bool isPkList;
        bool isAuthentication;
    }


    modifier checkWitnessPublicKey(bytes memory publicKey) {
        address pkAddr = DidUtils.addressFromPubKey(publicKey);
        require(msg.sender == pkAddr, "Check witness failed");
        _;
    }
    
    modifier checkWitnessController(bytes memory controller) {
        // TODO modify
        address pkAddr = DidUtils.addressFromPubKey(controller);
        require(msg.sender == pkAddr, "Check witness failed");
        _;
    }
    event Register(bytes id);
    function regIdWithPublicKey(bytes memory id, bytes memory publicKey) checkWitnessPublicKey(publicKey) public returns (bool) {
        // Make sure id and publicKey are not empty
        require(id.length > 0 && publicKey.length > 0, "Id or PublicKey cannot be empty");
        // Verify id is legal
        require(DidUtils.verifyId(id), "Id is illegal");
        require(id.length < 255, "Id is too long");
        require(!DidExist[id], "Id has been registerred");
        // Insert public key
        require(!_checkExistInArray(PublicKeyByIdByKey[id], publicKey), "Public key already exists");
        PublicKeyByIdByKey[id].push(PublicKey({
            key: publicKey,
            revoked: false,
            controller: id,
            isPkList: true,
            isAuthentication: true
        }));
        DidExist[id] = true;
        emit Register(id);
        return true;
    }
    function _checkExistInArray(PublicKey[] memory publicKeys, bytes memory key) internal pure returns (bool) {
        for (uint i = 0; i < publicKeys.length; i++) {
            if (BytesUtils.equal(publicKeys[i].key, key)) {
                return true;
            }
        }
        return false;
    }
    function regIdWithController(bytes memory id, bytes[] memory controller)  public returns (bool) {
            
    }
    
}
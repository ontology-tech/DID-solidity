pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "../libs/DidUtils.sol";
import "../interface/IDid.sol";
import "./MixinDidStorage.sol";
import "../libs/KeyUtils.sol";

contract DIDContract is MixinDidStorage, IDid {

    struct PublicKey {
        string id;
        string keyType;
        string[] controller;
        bytes pubKey;
        bool deActivated;
    }

    modifier didNotExisted(string memory did) {
        require(!data[KeyUtils.genStatusKey(did)].contains(KeyUtils.genStatusSencondKey()),
            "did existed");
        _;
    }

    modifier didActivated(string memory did) {
        string memory statusKey = KeyUtils.genStatusKey(did);
        bytes32 statusSencondKey = KeyUtils.genStatusSencondKey();
        require(data[statusKey].contains(statusSencondKey),
            "did not existed");
        bytes memory didStatus = data[statusKey].data[statusSencondKey].value;
        require(didStatus[0] == ACTIVATED,
            "did not activated");
        _;
    }

    modifier verifyPubKeySignature(bytes memory pubKey){
        require(DidUtils.pubKeyToAddr(pubKey) == msg.sender,
            "verify pub key failed");
        _;
    }

    modifier verifyDIDFormat(string memory did){
        require(DidUtils.verifyDIDFormat(did),
            "verify did signature failed");
        _;
    }

    modifier verifyDIDSignature(string memory did) {
        _;
    }

    constructor() public {

    }

    function regIDWithPublicKey(string memory did, bytes calldata pubKey) override public verifyDIDFormat(did) verifyPubKeySignature(pubKey) didNotExisted(did) {
        // set status to activated
        string memory statusKey = KeyUtils.genStatusKey(did);
        bytes32 statusSencondKey = KeyUtils.genStatusSencondKey();
        bytes memory status = new bytes(1);
        status[0] = ACTIVATED;
        data[statusKey].insert(statusSencondKey, status);
        // initialize default context
        // TODO: confirm default context
        string[] memory defaultCtx = new string[](2);
        defaultCtx[0] = "https://www.w3.org/ns/did/v1";
        defaultCtx[1] = "https://www.near.org/did/v1";
        insertContext(did, defaultCtx);
        // initialize a pubkey
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-1"));
        string[] memory defaultController = new string[](1);
        defaultController[0] = did;
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, defaultController, pubKey, false);
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pubKeyId);
        bytes memory encodedPubKey = abi.encode(pub.id, pub.keyType, pub.controller, pub.pubKey, pub.deActivated);
        data[pubKeyListKey].insert(pubKeyListSecondKey, encodedPubKey);
        // emit event
        emit Register(did);
    }

    function regIDWithController(string calldata did, string[] calldata controller, string calldata signerDID) override public verifyDIDFormat(did) verifyDIDSignature(signerDID) {

    }

    function addContext(string memory did, string[] memory contexts) override public verifyDIDSignature(did) {
        insertContext(did, contexts);
    }

    function addContextByController(string memory did, string[] memory contexts, string memory controller) override public verifyDIDSignature(controller) {
        insertContext(did, contexts);
    }

    function insertContext(string memory did, string[] memory contexts) private {
        string memory ctxKey = KeyUtils.genContextKey(did);
        for (uint i = 0; i < contexts.length; i++) {
            string memory ctx = contexts[i];
            bytes32 key = KeyUtils.genContextSecondKey(ctx);
            bool replaced = data[ctxKey].insert(key, bytes(ctx));
            if (!replaced) {
                emit AddContext(did, ctx);
            }
        }
    }

    function removeContext(string memory did, string[] memory contexts) override public verifyDIDSignature(did) {
        delContext(did, contexts);
    }

    function removeContextByController(string memory did, string[] memory contexts, string memory controller) override public verifyDIDSignature(controller) {
        delContext(did, contexts);
    }

    function delContext(string memory did, string[] memory contexts) private {
        string memory ctxKey = KeyUtils.genContextKey(did);
        for (uint i = 0; i < contexts.length; i++) {
            string memory ctx = contexts[i];
            bytes32 key = KeyUtils.genContextSecondKey(ctx);
            bool success = data[ctxKey].remove(key);
            if (success) {
                emit RemoveContext(did, ctx);
            }
        }
    }
}
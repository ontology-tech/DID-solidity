pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "../libs/DidUtils.sol";
import "../interface/IDid.sol";
import "./MixinDidStorage.sol";
import "../libs/KeyUtils.sol";
import "../libs/StringUtils.sol";

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

    function regIDWithPublicKey(string memory did, bytes memory pubKey)
    override public verifyDIDFormat(did) verifyPubKeySignature(pubKey) didNotExisted(did) {
        // set status to activated
        setDIDStatus(did, ACTIVATED);
        // initialize default context
        setDefaultCtx(did);
        // initialize a pubkey
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-1"));
        string[] memory defaultController = new string[](1);
        defaultController[0] = did;
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, defaultController, pubKey, false);
        appendPubKey(did, pub);
        // emit event
        emit Register(did);
    }

    // function regIDWithController(string memory did, string[] memory controller, string memory signerDID)
    // override public verifyDIDFormat(did) verifyDIDSignature(signerDID) didNotExisted(did) {
    //     // set status to activated
    //     setDIDActivated(did);
    //     // initialize default context
    //     setDefaultCtx(did);

    // }

    function revokeID(string memory did) override public verifyDIDSignature(did) {
        // set status to revoked
        setDIDStatus(did, REVOKED);
        // delete context
        delete data[KeyUtils.genContextKey(did)];
        // delete public key list
        delete data[KeyUtils.genPubKeyListKey(did)];
        // delete authentication list
        delete data[KeyUtils.genAuthListKey(did)];
        // TODO: clear other data
        emit Revoke(did);
    }

    // function revokeIDByController(string memory did, string memory controllerSigner) override public verifyDIDSignature(controllerSigner){
    //     // set status to revoked
    //     setDIDStatus(did, REVOKED);
    //     // delete context
    //     delete data[KeyUtils.genContextKey(did)];
    //     // delete public key list
    //     delete data[KeyUtils.genPubKeyListKey(did)];
    //     // delete authentication list
    //     delete data[KeyUtils.genAuthListKey(did)];
    //     // TODO: clear other data
    //     emit Revoke(did);
    // }

    function addController(string calldata did, string calldata controller) override external verifyDIDSignature(did) {
        // TODO:
    }


    function removeController(string calldata did, string calldata controller) override external verifyDIDSignature(did) {
        // TODO:
    }

    function addKey(string calldata did, bytes calldata newPubKey, string[] calldata pubKeyController) override external verifyDIDSignature(did) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        uint keyIndex = data[pubKeyListKey].keys.length;
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-", StringUtils.uint2str(keyIndex)));
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, pubKeyController, newPubKey, false);
        appendPubKey(did, pub);
        emit AddKey(did, newPubKey, pubKeyController);
    }

    function removeKey(string calldata did, bytes calldata pubKey) override external verifyDIDSignature(did) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pubKey);
        bool success = data[pubKeyListKey].remove(pubKeyListSecondKey);
        if (success) {
            emit RemoveKey(did, pubKey);
        }
    }

    function addNewAuthKey(string calldata did, bytes calldata pubKey, string[] calldata controller) override external verifyDIDSignature(did) {

    }

    function setDIDStatus(string memory did, byte _status) private {
        string memory statusKey = KeyUtils.genStatusKey(did);
        bytes32 statusSencondKey = KeyUtils.genStatusSencondKey();
        bytes memory status = new bytes(1);
        status[0] = _status;
        data[statusKey].insert(statusSencondKey, status);
    }

    // TODO: confirm default context
    function setDefaultCtx(string memory did) private {
        string[] memory defaultCtx = new string[](2);
        defaultCtx[0] = "https://www.w3.org/ns/did/v1";
        defaultCtx[1] = "https://www.near.org/did/v1";
        insertContext(did, defaultCtx);
    }

    function appendPubKey(string memory did, PublicKey memory pub) private {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pub.pubKey);
        bytes memory encodedPubKey = abi.encode(pub.id, pub.keyType, pub.controller, pub.pubKey, pub.deActivated);
        data[pubKeyListKey].insert(pubKeyListSecondKey, encodedPubKey);
    }

    function addContext(string memory did, string[] memory contexts) override public verifyDIDSignature(did) {
        insertContext(did, contexts);
    }

    // function addContextByController(string memory did, string[] memory contexts, string memory controller)
    // override public verifyDIDSignature(controller) {
    //     insertContext(did, contexts);
    // }

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

    // function removeContextByController(string memory did, string[] memory contexts, string memory controller)
    // override public verifyDIDSignature(controller) {
    //     delContext(did, contexts);
    // }

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

    function addController(string did, string controller)
    external
    returns (bool){
        // verify did signature

        // verify controller validity

        return true;
    }

    function addControllerByController(string id, string controller, string controllerSigner)
    external
    returns (bool){

        return true;
    }

    function removeController(string id, string controller)
    external
    returns (bool){
        return true;
    }

    function removeControllerByController(string id, string controller, string signer)
    external
    returns (bool) {
        return true;
    }

    // TODO
    function createTime(string did) private {
        byte32 key = genCreateTime(did);
        data.insert(key, now);
    }

    // TODO
    function updateTime(string did) private {
        byte32 key = genUpdateTime(did);
        data.insert(key, now);
    }
}
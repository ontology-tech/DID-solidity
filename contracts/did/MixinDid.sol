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
        bool isPubKey;
        bool isAuth;
    }

    modifier didNotExisted(string memory did) {
        require(!data[KeyUtils.genStatusKey(did)].contains(KeyUtils.genStatusSecondKey()),
            "did existed");
        _;
    }

    modifier didActivated(string memory did) {
        string memory statusKey = KeyUtils.genStatusKey(did);
        bytes32 statusSecondKey = KeyUtils.genStatusSecondKey();
        require(data[statusKey].contains(statusSecondKey),
            "did not existed");
        bytes memory didStatus = data[statusKey].data[statusSecondKey].value;
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
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, defaultController, pubKey, false, true, false);
        appendPubKey(did, pub);
        // emit event
        emit Register(did);
    }

    function deActiveID(string memory did) override public verifyDIDSignature(did) {
        // set status to revoked
        setDIDStatus(did, REVOKED);
        // delete context
        delete data[KeyUtils.genContextKey(did)];
        // delete public key list
        delete data[KeyUtils.genPubKeyListKey(did)];
        // TODO: clear other data
        emit DeActive(did);
    }

    function addKey(string memory did, bytes memory newPubKey, string[] memory pubKeyController) override public verifyDIDSignature(did) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        uint keyIndex = data[pubKeyListKey].keys.length + 1;
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-", StringUtils.uint2str(keyIndex)));
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, pubKeyController, newPubKey, false, true, false);
        bool replaced = appendPubKey(did, pub);
        if (!replaced) {
            emit AddKey(did, newPubKey, pubKeyController);
        }
    }

    function deActiveKey(string memory did, bytes memory pubKey) override public verifyDIDSignature(did) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pubKey);
        bytes memory pubKeyData = data[pubKeyListKey].data[pubKeyListSecondKey].value;
        string memory id;
        string memory keyType;
        string[] memory controller;
        bool deActivated;
        bool isPubKey;
        bool isAuth;
        // if pubKeyData is empty, this will faile transaction
        (id, keyType, controller, , deActivated, isPubKey, isAuth) = abi.decode(pubKeyData, (string, string, string[], bytes, bool, bool, bool));
        require(!deActivated);
        PublicKey memory key = PublicKey(id, keyType, controller, pubKey, true, isPubKey, isAuth);
        appendPubKey(did, key);
        emit DeActiveKey(did, pubKey);
    }

    function addNewAuthKey(string memory did, bytes memory pubKey, string[] memory controller) override public verifyDIDSignature(did) {
        bool replaced = appendAuthKey(did, pubKey, controller, false, true);
        require(!replaced, "pub key already existed");
        emit AddNewAuthKey(did, pubKey, controller);
    }

    function addNewAuthKeyByController(string memory did, bytes memory pubKey, string[] memory controller, string memory controllerSigner)
    override public verifyDIDSignature(controllerSigner) {
        bool replaced = appendAuthKey(did, pubKey, controller, false, true);
        require(!replaced, "pub key already existed");
        emit AddNewAuthKey(did, pubKey, controller);
    }

    function setAuthKey(string memory did, bytes memory pubKey) override public verifyDIDSignature(did) {
        authPubKey(did, pubKey);
    }

    function setAuthKeyByController(string memory did, bytes memory pubKey, string memory controller)
    override public verifyDIDSignature(controller) {
        authPubKey(did, pubKey);
    }

    function deActiveAuthKey(string memory did, bytes memory pubKey) override public verifyDIDSignature(did) {
        deAuthPubKey(did, pubKey);
    }

    function deActiveAuthKeyByController(string memory did, bytes memory pubKey, string memory controller)
    override public verifyDIDSignature(controller) {
        deAuthPubKey(did, pubKey);
    }

    function addContext(string memory did, string[] memory contexts) override public verifyDIDSignature(did) {
        insertContext(did, contexts);
    }

    function removeContext(string memory did, string[] memory contexts) override public verifyDIDSignature(did) {
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

    function setDIDStatus(string memory did, byte _status) private {
        string memory statusKey = KeyUtils.genStatusKey(did);
        bytes32 statusSecondKey = KeyUtils.genStatusSecondKey();
        bytes memory status = new bytes(1);
        status[0] = _status;
        data[statusKey].insert(statusSecondKey, status);
    }

    // TODO: confirm default context
    function setDefaultCtx(string memory did) private {
        string[] memory defaultCtx = new string[](2);
        defaultCtx[0] = "https://www.w3.org/ns/did/v1";
        defaultCtx[1] = "https://www.near.org/did/v1";
        insertContext(did, defaultCtx);
    }

    function authPubKey(string memory did, bytes memory pubKey) private {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pubKey);
        bytes memory pubKeyData = data[pubKeyListKey].data[pubKeyListSecondKey].value;
        bool isAuth;
        string[] memory controller;
        bool deActivated;
        // if pubKeyData is empty, this will faile transaction
        (, , controller, , deActivated, , isAuth) = abi.decode(pubKeyData, (string, string, string[], bytes, bool, bool, bool));
        require(!deActivated);
        require(!isAuth);
        appendAuthKey(did, pubKey, controller, true, true);
        emit SetAuthKey(did, pubKey);
    }

    function deAuthPubKey(string memory did, bytes memory pubKey) private {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pubKey);
        bytes memory pubKeyData = data[pubKeyListKey].data[pubKeyListSecondKey].value;
        bool isAuth;
        string[] memory controller;
        bool deActivated;
        // if pubKeyData is empty, this will faile transaction
        (, , controller, , deActivated, , isAuth) = abi.decode(pubKeyData, (string, string, string[], bytes, bool, bool, bool));
        require(!deActivated);
        require(isAuth);
        appendAuthKey(did, pubKey, controller, true, false);
        emit DeActiveAuthKey(did, pubKey);
    }

    function appendAuthKey(string memory did, bytes memory pubKey, string[] memory controller, bool isPubKey, bool auth) private returns (bool){
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        uint keyIndex = data[pubKeyListKey].keys.length + 1;
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-", StringUtils.uint2str(keyIndex)));
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, controller, pubKey, false, isPubKey, auth);
        return appendPubKey(did, pub);
    }

    function appendPubKey(string memory did, PublicKey memory pub) private returns (bool) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pub.pubKey);
        bytes memory encodedPubKey = abi.encode(pub.id, pub.keyType, pub.controller, pub.pubKey, pub.deActivated,
            pub.isPubKey, pub.isAuth);
        return data[pubKeyListKey].insert(pubKeyListSecondKey, encodedPubKey);
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
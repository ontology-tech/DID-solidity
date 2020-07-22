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
        bytes memory pubKey;
        bool keyIsDeActivated;
        bool keyIsAuth;
        bool verified;
        IterableMapping.itmap storage pubKeyList = data[KeyUtils.genPubKeyListKey(did)];
        for (
            uint i = pubKeyList.iterate_start();
            pubKeyList.iterate_valid(i);
            i = pubKeyList.iterate_next(i)
        ) {
            (, bytes memory pubKeyData) = pubKeyList.iterate_get(i);
            (, , , pubKey, keyIsDeActivated, , keyIsAuth) = abi.decode(pubKeyData, (string, string, string[], bytes, bool, bool, bool));
            if (keyIsDeActivated || !keyIsAuth) {
                continue;
            }
            if (DidUtils.pubKeyToAddr(pubKey) == msg.sender) {
                verified = true;
                break;
            }
        }
        require(verified);
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

    function deactivateID(string memory did) override public verifyDIDSignature(did) {
        // set status to revoked
        setDIDStatus(did, REVOKED);
        // delete context
        delete data[KeyUtils.genContextKey(did)];
        // delete public key list
        delete data[KeyUtils.genPubKeyListKey(did)];
        // TODO: clear other data
        emit Deactivate(did);
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

    function deactivateKey(string memory did, bytes memory pubKey) override public verifyDIDSignature(did) {
        PublicKey memory key = deserializePubKey(did, pubKey);
        appendPubKey(did, key);
        emit DeactivateKey(did, pubKey);
    }

    function addNewAuthKey(string memory did, bytes memory pubKey, string[] memory controller) override public verifyDIDSignature(did) {
        authNewPubKey(did, pubKey, controller);
    }

    function addNewAuthKeyByController(string memory did, bytes memory pubKey, string[] memory controller, string memory controllerSigner)
    override public verifyDIDSignature(controllerSigner) {
        authNewPubKey(did, pubKey, controller);
    }

    function setAuthKey(string memory did, bytes memory pubKey) override public verifyDIDSignature(did) {
        authPubKey(did, pubKey);
    }

    function setAuthKeyByController(string memory did, bytes memory pubKey, string memory controller)
    override public verifyDIDSignature(controller) {
        authPubKey(did, pubKey);
    }

    function deactivateAuthKey(string memory did, bytes memory pubKey) override public verifyDIDSignature(did) {
        deAuthPubKey(did, pubKey);
    }

    function deactivateAuthKeyByController(string memory did, bytes memory pubKey, string memory controller)
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

    function authNewPubKey(string memory did, bytes memory pubKey, string[] memory controller) private {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        uint keyIndex = data[pubKeyListKey].keys.length + 1;
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-", StringUtils.uint2str(keyIndex)));
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, controller, pubKey, false, false, true);
        bool replaced = appendPubKey(did, pub);
        require(!replaced, "key already existed");
        emit AddNewAuthKey(did, pubKey, controller);
    }

    function authPubKey(string memory did, bytes memory pubKey) private {
        PublicKey memory key = deserializePubKey(did, pubKey);
        require(!key.deActivated);
        require(!key.isAuth);
        key.isAuth = true;
        appendPubKey(did, key);
        emit SetAuthKey(did, pubKey);
    }

    function deAuthPubKey(string memory did, bytes memory pubKey) private {
        PublicKey memory key = deserializePubKey(did, pubKey);
        require(!key.deActivated);
        require(key.isAuth);
        key.isAuth = false;
        appendPubKey(did, key);
        emit DeactivateAuthKey(did, pubKey);
    }

    function deserializePubKey(string memory did, bytes memory pubKey) private view returns (PublicKey memory) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pubKey);
        bytes memory pubKeyData = data[pubKeyListKey].data[pubKeyListSecondKey].value;
        require(pubKeyData.length > 0);
        (string memory id, string memory keyType, string[] memory controller, , bool deActivated, bool isPubKey, bool isAuth)
        = abi.decode(pubKeyData, (string, string, string[], bytes, bool, bool, bool));
        PublicKey memory pub = PublicKey(id, keyType, controller, pubKey, deActivated, isPubKey, isAuth);
        return pub;
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

    function addController(string calldata did, string calldata controller)
    override
    external
    verifyDIDSignature(did) verifyDIDFormat(did) verifyDIDFormat(controller) {
        string memory controllerKey = KeyUtils.genControllerKey(did);
        bytes32 key = KeyUtils.genControllerSecondKey(controller);
        bool success = data[controllerKey].insert(key, bytes(controller));
        if (success) {
            emit AddController(did, controller);
        }
    }


    function removeController(string calldata did, string calldata controller)
    override
    external
    verifyDIDSignature(did) verifyDIDFormat(did) verifyDIDFormat(controller) {
        string memory controllerKey = KeyUtils.genControllerKey(did);
        bytes32 key = KeyUtils.genControllerSecondKey(controller);
        bool success = data[controllerKey].remove(key);
        if (success) {
            emit RemoveController(did, controller);
        }
    }

    function VerifyController(string calldata did, string calldata controller)
    override
    external
    verifyDIDFormat(did) verifyDIDFormat(controller) returns(bool){
        string memory controllerKey = KeyUtils.genControllerKey(did);
        bytes32 key = KeyUtils.genControllerSecondKey(controller);
        return data[controllerKey].contains(key);
    }


    function createTime(string memory did) private {
        string memory createTimekey = KeyUtils.genCreateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        data[createTimekey].insert(key, abi.encodePacked(now));
    }


    function updateTime(string memory did) private {
        string memory updateTimekey = KeyUtils.genUpdateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        data[updateTimekey].insert(key, abi.encodePacked(now));
    }

    function addService(string calldata did, string calldata serviceId, string calldata serviceType, string calldata serviceEndpoint)
    override
    external
    verifyDIDSignature(did) verifyDIDFormat(did){
        string memory serviceKey = KeyUtils.genServiceKey(did);
        bytes32 key = KeyUtils.genServiceSecondKey(did, serviceId);
        bool success = data[serviceKey].insert(key, abi.encodePacked(serviceId, serviceType, serviceEndpoint));
        if (success) {
            emit AddService(did, serviceId, serviceType, serviceEndpoint);
        }
    }

    function updateService(string calldata did, string calldata serviceId, string calldata serviceType, string calldata serviceEndpoint)
    override
    external
    verifyDIDSignature(did) verifyDIDFormat(did){
        string memory serviceKey = KeyUtils.genServiceKey(did);
        bytes32 key = KeyUtils.genServiceSecondKey(did, serviceId);
        bool success = data[serviceKey].insert(key, abi.encodePacked(serviceId, serviceType, serviceEndpoint));
        if (success) {
            emit UpdateService(did, serviceId, serviceType, serviceEndpoint);
        }
    }

    function removeService(string calldata did, string calldata serviceId)
    override
    external
    verifyDIDSignature(did) verifyDIDFormat(did){
        string memory serviceKey = KeyUtils.genServiceKey(did);
        bytes32 key = KeyUtils.genServiceSecondKey(did, serviceId);
        bool success = data[serviceKey].remove(key);
        if (success) {
            emit RemoveService(did, serviceId);
        }
    }
}
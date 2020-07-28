// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "../libs/DidUtils.sol";
import "../interface/IDid.sol";
import "./MixinDidStorage.sol";
import "../libs/KeyUtils.sol";
import "../libs/BytesUtils.sol";

contract DIDContract is MixinDidStorage, IDid {

    struct PublicKey {
        string id;
        string keyType;
        string[] controller;
        bytes pubKey;
        bool deactivated;
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
            "verify did format failed");
        _;
    }

    modifier verifyMultiDIDFormat(string[] memory dids){
        for (uint i = 0; i < dids.length; i++) {
            require(DidUtils.verifyDIDFormat(dids[i]),
                "verify did format failed");
        }
        _;
    }

    modifier onlyDIDOwner(string memory did) {
        require(verifyDIDSignature(did), "verify did signature failed");
        _;
    }

    function verifyDIDSignature(string memory did) private view returns (bool) {
        PublicKey[] memory allAuthKey = getAllAuthKey(did);
        for (uint i = 0; i < allAuthKey.length; i++) {
            if (DidUtils.pubKeyToAddr(allAuthKey[i].pubKey) == msg.sender) {
                return true;
            }
        }
        return false;
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
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, defaultController, pubKey, false, true, true);
        appendPubKey(did, pub);
        appendAuthOrder(did, pubKey);
        // update createTime and updateTime
        createTime(did);
        updateTime(did);
        // emit event
        emit Register(did);
    }

    function deactivateID(string memory did) override public onlyDIDOwner(did) {
        // set status to revoked
        setDIDStatus(did, REVOKED);
        // delete context
        delete data[KeyUtils.genContextKey(did)];
        // delete public key list
        delete data[KeyUtils.genPubKeyListKey(did)];
        // delete auth order
        delete data[KeyUtils.genAuthOrderKey(did)];
        // delete controller
        delete data[KeyUtils.genControllerKey(did)];
        // delete service
        delete data[KeyUtils.genServiceKey(did)];
        // delete create time
        delete data[KeyUtils.genCreateTimeKey(did)];
        // delete update time
        delete data[KeyUtils.genUpdateTimeKey(did)];
        emit Deactivate(did);
    }

    function addKey(string memory did, bytes memory newPubKey, string[] memory pubKeyController)
    override public onlyDIDOwner(did) verifyMultiDIDFormat(pubKeyController) {
        require(pubKeyController.length >= 1);
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        uint keyIndex = data[pubKeyListKey].keys.length + 1;
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-", BytesUtils.uint2str(keyIndex)));
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, pubKeyController, newPubKey, false, true, false);
        bool replaced = appendPubKey(did, pub);
        if (!replaced) {
            emit AddKey(did, newPubKey, pubKeyController);
        }
        // updateTime
        updateTime(did);
    }

    function deactivateKey(string memory did, bytes memory pubKey) override public onlyDIDOwner(did) {
        PublicKey memory key = deserializePubKey(did, pubKey);
        appendPubKey(did, key);
        emit DeactivateKey(did, pubKey);
        updateTime(did);
    }

    function addNewAuthKey(string memory did, bytes memory pubKey, string[] memory controller)
    override public onlyDIDOwner(did) verifyMultiDIDFormat(controller) {
        authNewPubKey(did, pubKey, controller);
        updateTime(did);
    }

    function addNewAuthKeyByController(string memory did, bytes memory pubKey, string[] memory controller, string memory controllerSigner)
    override public onlyDIDOwner(controllerSigner) verifyMultiDIDFormat(controller) {
        authNewPubKey(did, pubKey, controller);
        updateTime(did);
    }

    function setAuthKey(string memory did, bytes memory pubKey) override public onlyDIDOwner(did) {
        authPubKey(did, pubKey);
        updateTime(did);
    }

    function setAuthKeyByController(string memory did, bytes memory pubKey, string memory controller)
    override public onlyDIDOwner(controller) {
        authPubKey(did, pubKey);
        updateTime(did);
    }

    function deactivateAuthKey(string memory did, bytes memory pubKey) override public onlyDIDOwner(did) {
        deAuthPubKey(did, pubKey);
        updateTime(did);
    }

    function deactivateAuthKeyByController(string memory did, bytes memory pubKey, string memory controller)
    override public onlyDIDOwner(controller) {
        deAuthPubKey(did, pubKey);
        updateTime(did);
    }

    function addContext(string memory did, string[] memory contexts) override public onlyDIDOwner(did) {
        insertContext(did, contexts);
        updateTime(did);
    }

    function removeContext(string memory did, string[] memory contexts) override public onlyDIDOwner(did) {
        string memory ctxKey = KeyUtils.genContextKey(did);
        for (uint i = 0; i < contexts.length; i++) {
            string memory ctx = contexts[i];
            bytes32 key = KeyUtils.genContextSecondKey(ctx);
            bool success = data[ctxKey].remove(key);
            if (success) {
                emit RemoveContext(did, ctx);
            }
        }
        updateTime(did);
    }

    function addController(string memory did, string memory controller)
    override
    public
    onlyDIDOwner(did) verifyDIDFormat(did) {
        string memory controllerKey = KeyUtils.genControllerKey(did);
        bytes32 key = KeyUtils.genControllerSecondKey(controller);
        bool replaced = data[controllerKey].insert(key, bytes(controller));
        require(!replaced, "controller already existed");
        updateTime(did);
        emit AddController(did, controller);
    }


    function removeController(string memory did, string memory controller) override public onlyDIDOwner(did) {
        string memory controllerKey = KeyUtils.genControllerKey(did);
        bytes32 key = KeyUtils.genControllerSecondKey(controller);
        bool success = data[controllerKey].remove(key);
        require(success, "controller not existed");
        updateTime(did);
        emit RemoveController(did, controller);
    }

    function addService(string memory did, string memory serviceId, string memory serviceType, string memory serviceEndpoint)
    override public onlyDIDOwner(did) {
        string memory serviceKey = KeyUtils.genServiceKey(did);
        bytes32 key = KeyUtils.genServiceSecondKey(serviceId);
        bool replaced = data[serviceKey].insert(key, abi.encode(serviceId, serviceType, serviceEndpoint));
        require(!replaced, "service already existed");
        updateTime(did);
        emit AddService(did, serviceId, serviceType, serviceEndpoint);
    }

    function updateService(string memory did, string memory serviceId, string memory serviceType, string memory serviceEndpoint)
    override public onlyDIDOwner(did) {
        string memory serviceKey = KeyUtils.genServiceKey(did);
        bytes32 key = KeyUtils.genServiceSecondKey(serviceId);
        bool replaced = data[serviceKey].insert(key, abi.encode(serviceId, serviceType, serviceEndpoint));
        require(replaced, "service not existed");
        updateTime(did);
        emit UpdateService(did, serviceId, serviceType, serviceEndpoint);
    }

    function removeService(string memory did, string memory serviceId) override public onlyDIDOwner(did) {
        string memory serviceKey = KeyUtils.genServiceKey(did);
        bytes32 key = KeyUtils.genServiceSecondKey(serviceId);
        bool success = data[serviceKey].remove(key);
        require(success, "service not existed");
        updateTime(did);
        emit RemoveService(did, serviceId);
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
        defaultCtx[1] = "https://www.celo.org/did/v1";
        insertContext(did, defaultCtx);
    }

    function authNewPubKey(string memory did, bytes memory pubKey, string[] memory controller) private {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        uint keyIndex = data[pubKeyListKey].keys.length + 1;
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-", BytesUtils.uint2str(keyIndex)));
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, controller, pubKey, false, false, true);
        bool replaced = appendPubKey(did, pub);
        require(!replaced, "key already existed");
        bool authOrderReplaced = appendAuthOrder(did, pubKey);
        require(!authOrderReplaced, "key already existed in auth order");
        emit AddNewAuthKey(did, pubKey, controller);
    }

    function authPubKey(string memory did, bytes memory pubKey) private {
        PublicKey memory key = deserializePubKey(did, pubKey);
        require(!key.deactivated);
        require(!key.isAuth);
        key.isAuth = true;
        appendPubKey(did, key);
        bool authOrderReplaced = appendAuthOrder(did, pubKey);
        require(!authOrderReplaced, "key already existed in auth order");
        emit SetAuthKey(did, pubKey);
    }

    function deAuthPubKey(string memory did, bytes memory pubKey) private {
        PublicKey memory key = deserializePubKey(did, pubKey);
        require(!key.deactivated);
        require(key.isAuth);
        key.isAuth = false;
        appendPubKey(did, key);
        bool removeAuthOrderSuccess = removeAuthOrder(did, pubKey);
        require(removeAuthOrderSuccess, "remove auth order failed");
        emit DeactivateAuthKey(did, pubKey);
    }

    function deserializePubKey(string memory did, bytes memory pubKey) private view returns (PublicKey memory) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pubKey);
        bytes memory pubKeyData = data[pubKeyListKey].data[pubKeyListSecondKey].value;
        require(pubKeyData.length > 0);
        (string memory id, string memory keyType, string[] memory controller, , bool deactivated, bool isPubKey, bool isAuth)
        = abi.decode(pubKeyData, (string, string, string[], bytes, bool, bool, bool));
        PublicKey memory pub = PublicKey(id, keyType, controller, pubKey, deactivated, isPubKey, isAuth);
        return pub;
    }

    function appendPubKey(string memory did, PublicKey memory pub) private returns (bool) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pub.pubKey);
        bytes memory encodedPubKey = abi.encode(pub.id, pub.keyType, pub.controller, pub.pubKey, pub.deactivated,
            pub.isPubKey, pub.isAuth);
        return data[pubKeyListKey].insert(pubKeyListSecondKey, encodedPubKey);
    }

    function appendAuthOrder(string memory did, bytes memory pubKey) private returns (bool) {
        string memory authOrderKey = KeyUtils.genAuthOrderKey(did);
        bytes32 authOrderSecondKey = KeyUtils.genAuthOrderSecondKey(pubKey);
        return data[authOrderKey].insert(authOrderSecondKey, pubKey);
    }

    function removeAuthOrder(string memory did, bytes memory pubKey) private returns (bool) {
        string memory authOrderKey = KeyUtils.genAuthOrderKey(did);
        bytes32 authOrderSecondKey = KeyUtils.genAuthOrderSecondKey(pubKey);
        return data[authOrderKey].remove(authOrderSecondKey);
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

    function createTime(string memory did) private {
        string memory createTimekey = KeyUtils.genCreateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        data[createTimekey].insert(key, abi.encode(now));
    }


    function updateTime(string memory did) private {
        string memory updateTimekey = KeyUtils.genUpdateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        data[updateTimekey].insert(key, abi.encode(now));
    }

    function verifySignature(string memory did) public view returns (bool){
        return verifyDIDSignature(did);
    }

    function verifyController(string memory did, string memory controller) public view returns (bool){
        string memory controllerKey = KeyUtils.genControllerKey(did);
        bytes32 key = KeyUtils.genControllerSecondKey(controller);
        if (!data[controllerKey].contains(key)) {
            return false;
        }
        return verifyDIDSignature(controller);
    }

    function getAllPubKey(string memory did) verifyDIDFormat(did) public view returns (PublicKey[] memory) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        IterableMapping.itmap storage pubKeyList = data[pubKeyListKey];
        // first loop to calculate dynamic array size
        uint validKeySize = 0;
        PublicKey[] memory allKey = new PublicKey[](pubKeyList.size);
        uint count = 0;
        for (
            uint i = pubKeyList.iterate_start();
            pubKeyList.iterate_valid(i);
            i = pubKeyList.iterate_next(i)
        ) {
            (, bytes memory pubKeyData) = pubKeyList.iterate_get(i);
            (string memory id, string memory keyType, string[] memory controller, bytes memory pubKey, bool deactivated, bool isPubKey, bool isAuth)
            = abi.decode(pubKeyData, (string, string, string[], bytes, bool, bool, bool));
            allKey[count] = PublicKey(id, keyType, controller, pubKey, deactivated, isPubKey, isAuth);
            count++;
            if (deactivated || !isPubKey) {
                continue;
            }
            validKeySize++;
        }
        // second loop to filter result
        PublicKey[] memory result = new PublicKey[](validKeySize);
        count = 0;
        for (uint i = 0; i < allKey.length; i++) {
            if (!allKey[i].deactivated && allKey[i].isPubKey) {
                result[count] = allKey[i];
                count++;
            }
        }
        return result;
    }

    function getAllAuthKey(string memory did) verifyDIDFormat(did) public view returns (PublicKey[] memory) {
        string memory authOrderKey = KeyUtils.genAuthOrderKey(did);
        IterableMapping.itmap storage authOrder = data[authOrderKey];
        PublicKey[] memory result = new PublicKey[](authOrder.size);
        IterableMapping.itmap storage pubKeyList = data[KeyUtils.genPubKeyListKey(did)];
        uint count = 0;
        for (
            uint i = authOrder.iterate_start();
            authOrder.iterate_valid(i);
            i = authOrder.iterate_next(i)
        ) {
            (, bytes memory pubkey) = authOrder.iterate_get(i);
            bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pubkey);
            bytes memory pubKeyData = pubKeyList.data[pubKeyListSecondKey].value;
            (string memory id, string memory keyType, string[] memory controller, bytes memory pubKey, bool deactivated, bool isPubKey, bool isAuth)
            = abi.decode(pubKeyData, (string, string, string[], bytes, bool, bool, bool));
            result[count] = PublicKey(id, keyType, controller, pubKey, deactivated, isPubKey, isAuth);
            count++;
        }
        return result;
    }

    function getContext(string memory did) verifyDIDFormat(did) public view returns (string[] memory) {
        string memory ctxListKey = KeyUtils.genContextKey(did);
        IterableMapping.itmap storage ctxList = data[ctxListKey];
        string[] memory result = new string[](ctxList.size);
        uint count = 0;
        for (
            uint i = ctxList.iterate_start();
            ctxList.iterate_valid(i);
            i = ctxList.iterate_next(i)
        ) {
            (, bytes memory ctx) = ctxList.iterate_get(i);
            result[count] = string(ctx);
            count++;
        }
        return result;
    }

    function getAllController(string memory did) verifyDIDFormat(did) public view returns (string[] memory){
        string memory contollerListKey = KeyUtils.genControllerKey(did);
        IterableMapping.itmap storage controllerList = data[contollerListKey];
        string[] memory result = new string[](controllerList.size);
        uint count = 0;
        for (
            uint i = controllerList.iterate_start();
            controllerList.iterate_valid(i);
            i = controllerList.iterate_next(i)
        ) {
            (, bytes memory ctx) = controllerList.iterate_get(i);
            result[count] = string(ctx);
            count++;
        }
        return result;
    }

    struct Service {
        string serviceId;
        string serviceType;
        string serviceEndpoint;
    }

    function getAllService(string memory did) verifyDIDFormat(did) public view returns (Service[] memory){
        string memory serviceKey = KeyUtils.genServiceKey(did);
        IterableMapping.itmap storage serviceList = data[serviceKey];
        Service[] memory result = new Service[](serviceList.size);
        uint count = 0;
        for (
            uint i = serviceList.iterate_start();
            serviceList.iterate_valid(i);
            i = serviceList.iterate_next(i)
        ) {
            (, bytes memory serviceData) = serviceList.iterate_get(i);
            (string memory serviceId, string memory serviceType, string memory serviceEndpoint) =
            abi.decode(serviceData, (string, string, string));
            result[count] = Service(serviceId, serviceType, serviceEndpoint);
            count++;
        }
        return result;
    }

    function getCreatedTime(string memory did) verifyDIDFormat(did) public view returns (uint){
        string memory createTimekey = KeyUtils.genCreateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        bytes memory time = data[createTimekey].data[key].value;
        return abi.decode(time, (uint));
    }

    function getUpdatedTime(string memory did) verifyDIDFormat(did) public view returns (uint){
        string memory updateTimekey = KeyUtils.genUpdateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        bytes memory time = data[updateTimekey].data[key].value;
        return abi.decode(time, (uint));
    }

    struct DIDDocument {
        string[] context;
        string id;
        PublicKey[] publicKey;
        PublicKey[] authentication;
        string[] controller;
        Service[] service;
        uint created;
        uint updated;
    }

    function getDocument(string memory did) verifyDIDFormat(did) public didActivated(did)
    view returns (DIDDocument memory) {
        string[] memory context = getContext(did);
        PublicKey[] memory publicKey = getAllPubKey(did);
        PublicKey[] memory authentication = getAllAuthKey(did);
        string[] memory controller = getAllController(did);
        Service[] memory service = getAllService(did);
        uint created = getCreatedTime(did);
        uint updated = getUpdatedTime(did);
        return DIDDocument(context, did, publicKey, authentication, controller, service, created,
            updated);
    }
}
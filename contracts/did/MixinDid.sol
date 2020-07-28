// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "../libs/DidUtils.sol";
import "../interface/IDid.sol";
import "./MixinDidStorage.sol";
import "../libs/KeyUtils.sol";
import "../libs/BytesUtils.sol";

/**
 * @title DIDContract
 * @dev This contract is did logic implementation
 */
contract DIDContract is MixinDidStorage, IDid {

    // represent public key in did document
    struct PublicKey {
        string id; // public key id
        string keyType; // public key type, in ethereum, the type is always EcdsaSecp256k1VerificationKey2019
        string[] controller; // did array, has some permission
        bytes pubKey; // public key
        bool deactivated; // is deactivated or not
        bool isPubKey; // existed in public key list or not
        bool isAuth; // existed in authentication list or not
    }

    /**
    * @dev require did has not been registered, regardless of whether did is active or not
    */
    modifier didNotExisted(string memory did) {
        require(!data[KeyUtils.genStatusKey(did)].contains(KeyUtils.genStatusSecondKey()),
            "did existed");
        _;
    }

    /**
    * @dev require did is active
    */
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

    /**
    * @dev require msg.sender pass his public key while invoke,
    *      it means contract cannot invoke the function that modified by verifyPubKeySignature
    */
    modifier verifyPubKeySignature(bytes memory pubKey){
        require(DidUtils.pubKeyToAddr(pubKey) == msg.sender,
            "verify pub key failed");
        _;
    }

    /**
    * @dev require did format is legal
    */
    modifier verifyDIDFormat(string memory did){
        require(DidUtils.verifyDIDFormat(did),
            "verify did format failed");
        _;
    }

    /**
    * @dev require all did formats are legal
    */
    modifier verifyMultiDIDFormat(string[] memory dids){
        for (uint i = 0; i < dids.length; i++) {
            require(DidUtils.verifyDIDFormat(dids[i]),
                "verify did format failed");
        }
        _;
    }

    /**
    * @dev require msg.sender must be did,
    * it means public key of msg.sender must be one of did authentication
    */
    modifier onlyDIDOwner(string memory did) {
        require(verifyDIDSignature(did), "verify did signature failed");
        _;
    }

    /**
   * @dev verify there is one did authentication key sign this transaction
   * @param did did
   */
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

    /**
   * @dev use public key to register did, the public key will be added into authentication list
   * @param did did
   * @param pubKey public key
   */
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

    /**
   * @dev deactivate did, delete all document data of this did, but record did has been registered,
   *    it means this did cannot been registered in the future
   * @param did did
   */
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

    /**
   * @dev add a new public key to did public key list only, the key doesn't enter authentication list
   * @param did did
   * @param newPubKey new public key
   * @param pubKeyController controller of newPubKey, they are some did
   */
    function addKey(string memory did, bytes memory newPubKey, string[] memory pubKeyController)
    override public onlyDIDOwner(did) verifyMultiDIDFormat(pubKeyController) {
        require(pubKeyController.length >= 1);
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        uint keyIndex = data[pubKeyListKey].keys.length + 1;
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-", BytesUtils.uint2str(keyIndex)));
        PublicKey memory pub = PublicKey(pubKeyId, PUB_KEY_TYPE, pubKeyController, newPubKey, false, true, false);
        bool replaced = appendPubKey(did, pub);
        if (!replaced) {
            // updateTime
            updateTime(did);
            emit AddKey(did, newPubKey, pubKeyController);
        }
    }

    /**
   * @dev deactivate one key that existed in public key list
   * @param did did
   * @param pubKey public key
   */
    function deactivateKey(string memory did, bytes memory pubKey) override public onlyDIDOwner(did) {
        PublicKey memory key = deserializePubKey(did, pubKey);
        appendPubKey(did, key);
        emit DeactivateKey(did, pubKey);
        updateTime(did);
    }

    /**
   * @dev add a new public key to authentication list only, doesn't enter public key list
   * @param did did
   * @param pubKey the new public key
   * @param controller controller of newPubKey, they are some did
   */
    function addNewAuthKey(string memory did, bytes memory pubKey, string[] memory controller)
    override public onlyDIDOwner(did) verifyMultiDIDFormat(controller) {
        authNewPubKey(did, pubKey, controller);
        updateTime(did);
    }

    /**
   * @dev controller add a new public key to authentication list only, doesn't enter public key list
   * @param did did
   * @param pubKey the new public key
   * @param controller controller of newPubKey, they are some did
   * @param controllerSigner tx signer should be one of did controller
   */
    function addNewAuthKeyByController(string memory did, bytes memory pubKey, string[] memory controller,
        string memory controllerSigner) override public onlyDIDOwner(controllerSigner) verifyMultiDIDFormat(controller) {
        authNewPubKey(did, pubKey, controller);
        updateTime(did);
    }

    /**
   * @dev add one key existed in publicKey list to authentication list
   * @param did did
   * @param pubKey public key
   */
    function setAuthKey(string memory did, bytes memory pubKey) override public onlyDIDOwner(did) {
        authPubKey(did, pubKey);
        updateTime(did);
    }

    /**
   * @dev controller add one key existed in publicKey list to authentication list
   * @param did did
   * @param pubKey public key
   * @param controller one of did controller
   */
    function setAuthKeyByController(string memory did, bytes memory pubKey, string memory controller)
    override public onlyDIDOwner(controller) {
        authPubKey(did, pubKey);
        updateTime(did);
    }

    /**
   * @dev remove one key form authentication list
   * @param did did
   * @param pubKey public key
   */
    function deactivateAuthKey(string memory did, bytes memory pubKey) override public onlyDIDOwner(did) {
        deAuthPubKey(did, pubKey);
        updateTime(did);
    }

    /**
   * @dev controller remove one key from authentication list
   * @param did did
   * @param pubKey public key
   * @param controller one of did controller
   */
    function deactivateAuthKeyByController(string memory did, bytes memory pubKey, string memory controller)
    override public onlyDIDOwner(controller) {
        deAuthPubKey(did, pubKey);
        updateTime(did);
    }

    /**
   * @dev add context to did document
   * @param did did
   * @param contexts contexts
   */
    function addContext(string memory did, string[] memory contexts) override public onlyDIDOwner(did) {
        insertContext(did, contexts);
        updateTime(did);
    }

    /**
   * @dev remove context from did document
   * @param did did
   * @param contexts contexts
   */
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

    /**
   * @dev add one controller to did controller list
   * @param did did
   * @param controller one of did controller
   */
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

    /**
   * @dev remove controller from controller list
   * @param did did
   * @param controller one of did controller
   */
    function removeController(string memory did, string memory controller) override public onlyDIDOwner(did) {
        string memory controllerKey = KeyUtils.genControllerKey(did);
        bytes32 key = KeyUtils.genControllerSecondKey(controller);
        bool success = data[controllerKey].remove(key);
        require(success, "controller not existed");
        updateTime(did);
        emit RemoveController(did, controller);
    }

    /**
   * @dev add service to did service list
   * @param did did
   * @param serviceId service id
   * @param serviceType service type
   * @param serviceEndpoint service endpoint
   */
    function addService(string memory did, string memory serviceId, string memory serviceType, string memory serviceEndpoint)
    override public onlyDIDOwner(did) {
        string memory serviceKey = KeyUtils.genServiceKey(did);
        bytes32 key = KeyUtils.genServiceSecondKey(serviceId);
        bool replaced = data[serviceKey].insert(key, abi.encode(serviceId, serviceType, serviceEndpoint));
        require(!replaced, "service already existed");
        updateTime(did);
        emit AddService(did, serviceId, serviceType, serviceEndpoint);
    }

    /**
   * @dev update service
   * @param did did
   * @param serviceId service id
   * @param serviceType service type
   * @param serviceEndpoint service endpoint
   */
    function updateService(string memory did, string memory serviceId, string memory serviceType, string memory serviceEndpoint)
    override public onlyDIDOwner(did) {
        string memory serviceKey = KeyUtils.genServiceKey(did);
        bytes32 key = KeyUtils.genServiceSecondKey(serviceId);
        bool replaced = data[serviceKey].insert(key, abi.encode(serviceId, serviceType, serviceEndpoint));
        require(replaced, "service not existed");
        updateTime(did);
        emit UpdateService(did, serviceId, serviceType, serviceEndpoint);
    }

    /**
   * @dev remove service
   * @param did did
   * @param serviceId service id
   */
    function removeService(string memory did, string memory serviceId) override public onlyDIDOwner(did) {
        string memory serviceKey = KeyUtils.genServiceKey(did);
        bytes32 key = KeyUtils.genServiceSecondKey(serviceId);
        bool success = data[serviceKey].remove(key);
        require(success, "service not existed");
        updateTime(did);
        emit RemoveService(did, serviceId);
    }

    /**
   * @dev set did status, status is ACTIVATED or REVOKED
   * @param did did
   * @param _status did status
   */
    function setDIDStatus(string memory did, byte _status) private {
        string memory statusKey = KeyUtils.genStatusKey(did);
        bytes32 statusSecondKey = KeyUtils.genStatusSecondKey();
        bytes memory status = new bytes(1);
        status[0] = _status;
        data[statusKey].insert(statusSecondKey, status);
    }

    /**
   * @dev set default context, all did has these contexts
   * @param did did
   */
    function setDefaultCtx(string memory did) private {
        string[] memory defaultCtx = new string[](1);
        defaultCtx[0] = "https://www.w3.org/ns/did/v1";
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

    /**
   * @dev remove public key from authentication list
   * @param did did
   * @param pubKey public key
   */
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

    /**
   * @dev read storage public key and deserialize it to PublicKey struct
   * @param did did
   * @param pubKey public key
   */
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

    /**
   * @dev authOrder used to sort authentication list
   * @param did did
   * @param pubKey authentication public key
   */
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

    /**
   * @dev record did created time
   * @param did did
   */
    function createTime(string memory did) private {
        string memory createTimekey = KeyUtils.genCreateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        data[createTimekey].insert(key, abi.encode(now));
    }


    /**
   * @dev record did updated time
   * @param did did
   */
    function updateTime(string memory did) private {
        string memory updateTimeKey = KeyUtils.genUpdateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        data[updateTimeKey].insert(key, abi.encode(now));
    }

    /**
   * @dev verify tx has signed by did
   * @param did did
   */
    function verifySignature(string memory did) public view returns (bool){
        return verifyDIDSignature(did);
    }

    /**
   * @dev verify tx has signed by did controller
   * @param did did
   * @param controller one of did controller
   */
    function verifyController(string memory did, string memory controller) public view returns (bool){
        string memory controllerKey = KeyUtils.genControllerKey(did);
        bytes32 key = KeyUtils.genControllerSecondKey(controller);
        if (!data[controllerKey].contains(key)) {
            return false;
        }
        return verifyDIDSignature(controller);
    }

    /**
   * @dev query public key list
   * @param did did
   */
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

    /**
   * @dev query authentication list
   * @param did did
   */
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

    /**
   * @dev query context list
   * @param did did
   */
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

    /**
   * @dev query controller list
   * @param did did
   */
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

    /**
   * @dev query service list
   * @param did did
   */
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

    /**
   * @dev query did created time
   * @param did did
   */
    function getCreatedTime(string memory did) verifyDIDFormat(did) public view returns (uint){
        string memory createTimekey = KeyUtils.genCreateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        bytes memory time = data[createTimekey].data[key].value;
        return abi.decode(time, (uint));
    }

    /**
   * @dev query did updated time
   * @param did did
   */
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

    /**
   * @dev query document
   * @param did did
   */
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
// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "../interface/IDid.sol";
import "./MixinDidStorage.sol";
import "../libs/DidUtils.sol";
import "../libs/KeyUtils.sol";
import "../libs/BytesUtils.sol";
import "../libs/ZeroCopySink.sol";
import "../libs/ZeroCopySource.sol";
import "../libs/StorageUtils.sol";

/**
 * @title DIDContract
 * @dev This contract is did logic implementation
 */
contract DIDContractV2 is MixinDidStorage, IDid {

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
        StorageUtils.PublicKey[] memory allAuthKey = getAllAuthKey(did);
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
    override public verifyDIDFormat(did) verifyPubKeySignature(pubKey) {
        did = BytesUtils.toLower(did);
        require(!didStatus[did].existed, 'did already existed');
        // initialize a pubkey
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-1"));
        string[] memory defaultController = new string[](1);
        defaultController[0] = did;
        StorageUtils.PublicKey memory pub = StorageUtils.PublicKey(pubKeyId, PUB_KEY_TYPE, defaultController, pubKey,
            false, true, true, 1);
        appendPubKey(did, pub);
        // update createTime
        createTime(did);
        // record did status
        didStatus[did] = DIDStatus(true, true, "1", 1);
        // emit event
        emit Register(did);
    }

    /**
   * @dev deactivate did, delete all document data of this did, but record did has been registered,
   *    it means this did cannot been registered in the future
   * @param did did
   */
    function deactivateID(string memory did) override public onlyDIDOwner(did) {
        // delete context
        delete data[KeyUtils.genContextKey(did)];
        // delete public key list
        delete data[KeyUtils.genPubKeyListKey(did)];
        // delete controller
        delete data[KeyUtils.genControllerKey(did)];
        // delete service
        delete data[KeyUtils.genServiceKey(did)];
        // delete create time
        delete data[KeyUtils.genCreateTimeKey(did)];
        // delete update time
        delete data[KeyUtils.genUpdateTimeKey(did)];
        // update status
        didStatus[did].activated = false;
        didStatus[did].authListLen = 0;
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
        StorageUtils.PublicKey memory pub = StorageUtils.PublicKey(pubKeyId, PUB_KEY_TYPE, pubKeyController,
            newPubKey, false, true, false, 0);
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
        StorageUtils.PublicKey memory key = deserializePubKey(did, pubKey);
        key.isPubKey = false;
        key.isAuth = false;
        key.deactivated = true;
        key.authIndex = 0;
        appendPubKey(did, key);
        updateTime(did);
        emit DeactivateKey(did, pubKey);
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
    override public onlyDIDOwner(did) {
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
        StorageUtils.Service memory service = StorageUtils.Service(serviceId, serviceType, serviceEndpoint);
        bytes memory serviceBytes = StorageUtils.serializeService(service);
        bool replaced = data[serviceKey].insert(key, serviceBytes);
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
        StorageUtils.Service memory service = StorageUtils.Service(serviceId, serviceType, serviceEndpoint);
        bytes memory serviceBytes = StorageUtils.serializeService(service);
        bool replaced = data[serviceKey].insert(key, serviceBytes);
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

    function authNewPubKey(string memory did, bytes memory pubKey, string[] memory controller) private {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        uint keyIndex = data[pubKeyListKey].keys.length + 1;
        did = BytesUtils.toLower(did);
        uint authIndex = didStatus[did].authListLen + 1;
        didStatus[did].authListLen = authIndex;
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-", BytesUtils.uint2str(keyIndex)));
        StorageUtils.PublicKey memory pub = StorageUtils.PublicKey(pubKeyId, PUB_KEY_TYPE, controller, pubKey,
            false, false, true, authIndex);
        bool replaced = appendPubKey(did, pub);
        require(!replaced, "key already existed");
        emit AddNewAuthKey(did, pubKey, controller);
    }

    function authPubKey(string memory did, bytes memory pubKey) private {
        StorageUtils.PublicKey memory key = deserializePubKey(did, pubKey);
        require(!key.deactivated);
        require(!key.isAuth);
        key.isAuth = true;
        did = BytesUtils.toLower(did);
        key.authIndex = didStatus[did].authListLen + 1;
        didStatus[did].authListLen = key.authIndex;
        appendPubKey(did, key);
        emit SetAuthKey(did, pubKey);
    }

    /**
   * @dev remove public key from authentication list
   * @param did did
   * @param pubKey public key
   */
    function deAuthPubKey(string memory did, bytes memory pubKey) private {
        StorageUtils.PublicKey memory key = deserializePubKey(did, pubKey);
        require(!key.deactivated);
        require(key.isAuth);
        key.isAuth = false;
        key.authIndex = 0;
        appendPubKey(did, key);
        emit DeactivateAuthKey(did, pubKey);
    }

    /**
   * @dev read storage public key and deserialize it to PublicKey struct
   * @param did did
   * @param pubKey public key
   */
    function deserializePubKey(string memory did, bytes memory pubKey) private view returns (StorageUtils.PublicKey memory) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pubKey);
        bytes memory pubKeyData = data[pubKeyListKey].data[pubKeyListSecondKey].value;
        require(pubKeyData.length > 0);
        StorageUtils.PublicKey memory pub = StorageUtils.deserializePubKey(pubKeyData);
        return pub;
    }

    function appendPubKey(string memory did, StorageUtils.PublicKey memory pub) private returns (bool) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        bytes32 pubKeyListSecondKey = KeyUtils.genPubKeyListSecondKey(pub.pubKey);
        bytes memory encodedPubKey = StorageUtils.serializePubKey(pub);
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

    /**
   * @dev record did created time
   * @param did did
   */
    function createTime(string memory did) private {
        string memory createTimeKey = KeyUtils.genCreateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        data[createTimeKey].insert(key, ZeroCopySink.WriteUint255(now));
    }


    /**
   * @dev record did updated time
   * @param did did
   */
    function updateTime(string memory did) private {
        string memory updateTimeKey = KeyUtils.genUpdateTimeKey(did);
        bytes32 key = KeyUtils.genUpdateTimeSecondKey();
        data[updateTimeKey].insert(key, ZeroCopySink.WriteUint255(now));
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
    function getAllPubKey(string memory did)
    public view returns (StorageUtils.PublicKey[] memory) {
        string memory pubKeyListKey = KeyUtils.genPubKeyListKey(did);
        IterableMapping.itmap storage pubKeyList = data[pubKeyListKey];
        return StorageUtils.getAllPubKey(pubKeyList);
    }

    /**
   * @dev query authentication list
   * @param did did
   */
    function getAllAuthKey(string memory did)
    public view returns (StorageUtils.PublicKey[] memory) {
        IterableMapping.itmap storage pubKeyList = data[KeyUtils.genPubKeyListKey(did)];
        return StorageUtils.getAllAuthKey(pubKeyList);
    }

    /**
   * @dev query context list
   * @param did did
   */
    function getContext(string memory did)
    public view returns (string[] memory) {
        string memory ctxListKey = KeyUtils.genContextKey(did);
        IterableMapping.itmap storage ctxList = data[ctxListKey];
        return StorageUtils.getContext(ctxList);
    }

    /**
   * @dev query controller list
   * @param did did
   */
    function getAllController(string memory did)
    public view returns (string[] memory){
        string memory controllerListKey = KeyUtils.genControllerKey(did);
        IterableMapping.itmap storage controllerList = data[controllerListKey];
        return StorageUtils.getAllController(controllerList);
    }

    /**
   * @dev query service list
   * @param did did
   */
    function getAllService(string memory did)
    public view returns (StorageUtils.Service[] memory){
        string memory serviceKey = KeyUtils.genServiceKey(did);
        IterableMapping.itmap storage serviceList = data[serviceKey];
        return StorageUtils.getAllService(serviceList);
    }

    /**
   * @dev query did created time
   * @param did did
   */
    function getCreatedTime(string memory did)
    public view returns (uint){
        string memory createTimeKey = KeyUtils.genCreateTimeKey(did);
        bytes32 key = KeyUtils.genCreateTimeSecondKey();
        bytes memory time = data[createTimeKey].data[key].value;
        (uint256 result,) = ZeroCopySource.NextUint255(time, 0);
        return result;
    }

    /**
   * @dev query did updated time
   * @param did did
   */
    function getUpdatedTime(string memory did)
    public view returns (uint){
        string memory updateTimeKey = KeyUtils.genUpdateTimeKey(did);
        bytes32 key = KeyUtils.genUpdateTimeSecondKey();
        bytes memory time = data[updateTimeKey].data[key].value;
        if (time.length == 0) {
            return getCreatedTime(did);
        }
        (uint256 result,) = ZeroCopySource.NextUint255(time, 0);
        return result;
    }

    /**
   * @dev query document
   * @param did did
   */
    function getDocument(string memory did) public
    view returns (StorageUtils.DIDDocument memory) {
        string[] memory context = getContext(did);
        StorageUtils.PublicKey[] memory publicKey = getAllPubKey(did);
        StorageUtils.PublicKey[] memory authentication = getAllAuthKey(did);
        string[] memory controller = getAllController(did);
        StorageUtils.Service[] memory service = getAllService(did);
        uint created = getCreatedTime(did);
        uint updated = getUpdatedTime(did);
        return StorageUtils.DIDDocument(context, did, publicKey, authentication, controller, service, created,
            updated);
    }
}
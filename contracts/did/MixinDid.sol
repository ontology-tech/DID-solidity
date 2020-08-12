// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "../interface/IDid.sol";
import "../libs/DidUtils.sol";
import "../libs/BytesUtils.sol";
import "../libs/StorageUtils.sol";

/**
 * @title DIDContract
 * @dev This contract is did logic implementation
 */
contract DIDContract is IDid {
    mapping(string => StorageUtils.DIDDocument) public data; // data storage

    // did => deactivated
    mapping(string => bool) public deactivatedDID;

    // did => authentication list index
    mapping(string => uint) public authListIndex;

    modifier didActivated(string memory did){
        require(!deactivatedDID[BytesUtils.toLower(did)], "did is deactivated");
        _;
    }

    modifier notSelfAddr(string memory did, address addr){
        address didAddr = DidUtils.parseAddrFromDID(bytes(did));
        require(didAddr != addr, "no need to add self addr");
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
    modifier requireDIDSign(string memory did) {
        require(verifySignature(did), "verify did signature failed");
        _;
    }

    modifier requireDIDControllerSign(string memory did, string memory controller){
        require(verifyController(did, controller), "verify did controller signature failed");
        _;
    }

    constructor() public {

    }

    /**
   * @dev deactivate did, delete all document data of this did, but record did has been registered,
   *    it means this did cannot been registered in the future
   * @param did did
   */
    function deactivateID(string memory did)
    requireDIDSign(did) didActivated(did)
    override public {
        did = BytesUtils.toLower(did);
        delete data[did];
        // delete context
        deactivatedDID[did] = true;
        // delete authListIndex
        delete authListIndex[did];
        emit Deactivate(did);
    }

    /**
   * @dev add a new public key to did public key list only, the key doesn't enter authentication list
   * @param did did
   * @param newPubKey new public key
   * @param controller controller of newPubKey, they are some did
   */
    function addKey(string memory did, bytes memory newPubKey, string[] memory controller)
    requireDIDSign(did) verifyMultiDIDFormat(controller)
    override public {
        addNewPubKey(did, newPubKey, address(0), StorageUtils.KEY_TYPE_PUB, controller, true, 0);
        emit AddKey(did, newPubKey, controller);
    }

    /**
    * @dev add a new address to did public key list only, the key doesn't enter authentication list
    * @param did did
    * @param addr new address
    * @param controller controller of newPubKey, they are some did
    */
    function addAddr(string memory did, address addr, string[] memory controller)
    requireDIDSign(did) verifyMultiDIDFormat(controller) notSelfAddr(did, addr)
    override public {
        bytes memory emptyPubKey = new bytes(0);
        addNewPubKey(did, emptyPubKey, addr, StorageUtils.KEY_TYPE_ADDR, controller, true, 0);
        emit AddAddr(did, addr, controller);
    }

    /**
   * @dev add a new public key to authentication list only, doesn't enter public key list
   * @param did did
   * @param pubKey the new public key
   * @param controller controller of newPubKey, they are some did
   */
    function addNewAuthKey(string memory did, bytes memory pubKey, string[] memory controller)
    requireDIDSign(did) verifyMultiDIDFormat(controller)
    override public {
        addNewPubKey(did, pubKey, address(0), StorageUtils.KEY_TYPE_PUB, controller,
            false, fetchAuthIndex(did));
        emit AddNewAuthKey(did, pubKey, controller);
    }

    /**
   * @dev add a new address to authentication list only, doesn't enter public key list
   * @param did did
   * @param addr the new address
   * @param controller controller of newPubKey, they are some did
   */
    function addNewAuthAddr(string memory did, address addr, string[] memory controller)
    requireDIDSign(did) verifyMultiDIDFormat(controller) notSelfAddr(did, addr)
    override public {
        bytes memory emptyPubKey = new bytes(0);
        uint authIndex = fetchAuthIndex(did);
        addNewPubKey(did, emptyPubKey, addr, StorageUtils.KEY_TYPE_ADDR, controller, false, authIndex);
        emit AddNewAuthAddr(did, addr, controller);
    }

    /**
   * @dev controller add a new public key to authentication list only, doesn't enter public key list
   * @param did did
   * @param pubKey the new public key
   * @param controller controller of newPubKey, they are some did
   * @param controllerSigner tx signer should be one of did controller
   */
    function addNewAuthKeyByController(string memory did, bytes memory pubKey, string[] memory controller,
        string memory controllerSigner)
    requireDIDControllerSign(did, controllerSigner) verifyMultiDIDFormat(controller)
    override public {
        addNewPubKey(did, pubKey, address(0), StorageUtils.KEY_TYPE_PUB, controller,
            false, fetchAuthIndex(did));
        emit AddNewAuthKey(did, pubKey, controller);
    }

    /**
   * @dev controller add a new address to authentication list only, doesn't enter public key list
   * @param did did
   * @param addr the new address
   * @param controller controller of newPubKey, they are some did
   * @param controllerSigner tx signer should be one of did controller
   */
    function addNewAuthAddrByController(string memory did, address addr, string[] memory controller,
        string memory controllerSigner)
    requireDIDControllerSign(did, controllerSigner) verifyMultiDIDFormat(controller) notSelfAddr(did, addr)
    override public {
        bytes memory emptyPubKey = new bytes(0);
        uint authIndex = fetchAuthIndex(did);
        addNewPubKey(did, emptyPubKey, addr, StorageUtils.KEY_TYPE_ADDR, controller,
            false, authIndex);
        emit AddNewAuthAddr(did, addr, controller);
    }

    function addNewPubKey(string memory did, bytes memory pubKey, address addr, string memory keyType,
        string[] memory controller, bool isPub, uint authIndex)
    private {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        StorageUtils.addNewPubKey(document, did, pubKey, addr, keyType, controller, isPub, authIndex);
    }

    /**
   * @dev add one key existed in publicKey list to authentication list
   * @param did did
   * @param pubKey public key
   */
    function setAuthKey(string memory did, bytes memory pubKey)
    requireDIDSign(did)
    override public {
        authPubKey(did, pubKey, address(0));
        emit SetAuthKey(did, pubKey);
    }

    /**
   * @dev add one address existed in publicKey list to authentication list
   * @param did did
   * @param addr address
   */
    function setAuthAddr(string memory did, address addr)
    requireDIDSign(did)
    override public {
        bytes memory pubKey = new bytes(0);
        authPubKey(did, pubKey, addr);
        emit SetAuthAddr(did, addr);
    }

    /**
   * @dev controller add one key existed in publicKey list to authentication list
   * @param did did
   * @param pubKey public key
   * @param controller one of did controller
   */
    function setAuthKeyByController(string memory did, bytes memory pubKey, string memory controller)
    requireDIDControllerSign(did, controller)
    override public {
        authPubKey(did, pubKey, address(0));
        emit SetAuthKey(did, pubKey);
    }

    /**
   * @dev controller add one address existed in publicKey list to authentication list
   * @param did did
   * @param addr address
   * @param controller one of did controller
   */
    function setAuthAddrByController(string memory did, address addr, string memory controller)
    requireDIDControllerSign(did, controller)
    override public {
        bytes memory pubKey = new bytes(0);
        authPubKey(did, pubKey, addr);
        emit SetAuthAddr(did, addr);
    }

    function authPubKey(string memory did, bytes memory pubKey, address addr) private {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        StorageUtils.authPubKey(document, pubKey, addr, fetchAuthIndex(did));
    }

    function fetchAuthIndex(string memory did) private returns (uint){
        did = BytesUtils.toLower(did);
        uint authIndex = authListIndex[did] + 2;
        // this means each auth key index increased 2 every time
        authListIndex[did] = authIndex;
        return authIndex;
    }

    /**
   * @dev deactivate one key that existed in public key list
   * @param did did
   * @param pubKey public key
   */
    function deactivateKey(string memory did, bytes memory pubKey)
    requireDIDSign(did)
    override public {
        deactivatePubKey(did, pubKey, address(0));
        emit DeactivateKey(did, pubKey);
    }

    /**
   * @dev deactivate one addr that existed in public key list
   * @param did did
   * @param addr address
   */
    function deactivateAddr(string memory did, address addr)
    requireDIDSign(did)
    override public {
        bytes memory emptyPubKey = new bytes(0);
        deactivatePubKey(did, emptyPubKey, addr);
        emit DeactivateAddr(did, addr);
    }

    function deactivatePubKey(string memory did, bytes memory pubKey, address addr)
    private {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        StorageUtils.deactivatePubKey(document, pubKey, addr);
    }

    /**
   * @dev remove one key from authentication list
   * @param did did
   * @param pubKey public key
   */
    function deactivateAuthKey(string memory did, bytes memory pubKey)
    requireDIDSign(did)
    override public {
        deAuthPubKey(did, pubKey, address(0));
        emit DeactivateAuthKey(did, pubKey);
    }

    /**
   * @dev remove one address from authentication list
   * @param did did
   * @param addr address
   */
    function deactivateAuthAddr(string memory did, address addr)
    requireDIDSign(did)
    override public {
        bytes memory pubKey = new bytes(0);
        deAuthPubKey(did, pubKey, addr);
        emit DeactivateAuthAddr(did, addr);
    }

    /**
   * @dev controller remove one key from authentication list
   * @param did did
   * @param pubKey public key
   * @param controller one of did controller
   */
    function deactivateAuthKeyByController(string memory did, bytes memory pubKey, string memory controller)
    requireDIDControllerSign(did, controller)
    override public {
        deAuthPubKey(did, pubKey, address(0));
        emit DeactivateAuthKey(did, pubKey);
    }

    /**
   * @dev controller remove one address from authentication list
   * @param did did
   * @param addr address
   * @param controller one of did controller
   */
    function deactivateAuthAddrByController(string memory did, address addr, string memory controller)
    requireDIDControllerSign(did, controller)
    override public {
        bytes memory pubKey = new bytes(0);
        deAuthPubKey(did, pubKey, addr);
        emit DeactivateAuthAddr(did, addr);
    }

    /**
   * @dev remove public key from authentication list
   * @param did did
   * @param pubKey public key
   */
    function deAuthPubKey(string memory did, bytes memory pubKey, address addr) private {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        StorageUtils.deAuthPubKey(document, pubKey, addr);
    }

    /**
   * @dev add context to did document
   * @param did did
   * @param contexts contexts
   */
    function addContext(string memory did, string[] memory contexts)
    requireDIDSign(did)
    override public {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        for (uint i = 0; i < contexts.length; i++) {
            if (StorageUtils.addContext(document, contexts[i])) {
                emit AddContext(did, contexts[i]);
            }
        }
        document.updated = now;
    }

    /**
   * @dev remove context from did document
   * @param did did
   * @param contexts contexts
   */
    function removeContext(string memory did, string[] memory contexts)
    requireDIDSign(did)
    override public {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        for (uint i = 0; i < contexts.length; i++) {
            if (StorageUtils.removeContext(document, contexts[i])) {
                emit RemoveContext(did, contexts[i]);
            }
        }
        document.updated = now;
    }

    /**
   * @dev add one controller to did controller list
   * @param did did
   * @param controller one of did controller
   */
    function addController(string memory did, string memory controller)
    requireDIDSign(did)
    override public {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        StorageUtils.addController(document, controller);
        document.updated = now;
        emit AddController(did, controller);
    }

    /**
   * @dev remove controller from controller list
   * @param did did
   * @param controller one of did controller
   */
    function removeController(string memory did, string memory controller)
    requireDIDSign(did)
    override public {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        StorageUtils.removeController(document, controller);
        emit RemoveController(did, controller);
    }

    /**
   * @dev add service to did service list
   * @param did did
   * @param serviceId service id
   * @param serviceType service type
   * @param serviceEndpoint service endpoint
   */
    function addService(string memory did, string memory serviceId, string memory serviceType,
        string memory serviceEndpoint)
    requireDIDSign(did)
    override public {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        StorageUtils.addService(document, serviceId, serviceType, serviceEndpoint);
        document.updated = now;
        emit AddService(did, serviceId, serviceType, serviceEndpoint);
    }

    /**
   * @dev update service
   * @param did did
   * @param serviceId service id
   * @param serviceType service type
   * @param serviceEndpoint service endpoint
   */
    function updateService(string memory did, string memory serviceId, string memory serviceType,
        string memory serviceEndpoint)
    requireDIDSign(did)
    override public {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        StorageUtils.updateService(document, serviceId, serviceType, serviceEndpoint);
        emit UpdateService(did, serviceId, serviceType, serviceEndpoint);
    }

    /**
   * @dev remove service
   * @param did did
   * @param serviceId service id
   */
    function removeService(string memory did, string memory serviceId)
    requireDIDSign(did)
    override public {
        did = BytesUtils.toLower(did);
        StorageUtils.DIDDocument storage document = data[did];
        StorageUtils.removeService(document, serviceId);
        emit RemoveService(did, serviceId);
    }

    /**
   * @dev verify tx has signed by did
   * @param did did
   */
    function verifySignature(string memory did)
    public view returns (bool)
    {
        did = BytesUtils.toLower(did);
        if (deactivatedDID[did]) {
            return false;
        }
        StorageUtils.PublicKey[] memory allAuthKey = StorageUtils.getAllAuthKey(data[did],
            did, StorageUtils.KEY_TYPE_ADDR);
        for (uint i = 0; i < allAuthKey.length; i++) {
            if (allAuthKey[i].ethAddr == msg.sender) {
                return true;
            }
            if (allAuthKey[i].pubKey.length > 0 &&
                DidUtils.pubKeyToAddr(allAuthKey[i].pubKey) == msg.sender) {
                return true;
            }
        }
        return false;
    }

    /**
   * @dev verify tx has signed by did controller
   * @param did did
   * @param controller one of did controller
   */
    function verifyController(string memory did, string memory controller)
    public view returns (bool){
        did = BytesUtils.toLower(did);
        if (deactivatedDID[did]) {
            return false;
        }
        StorageUtils.DIDDocument storage document = data[did];
        string[] memory ctrls = document.controller;
        bool existed = false;
        for (uint i = 0; i < ctrls.length; i++) {
            if (BytesUtils.strEqual(controller, ctrls[i])) {
                existed = true;
                break;
            }
        }
        return existed && verifySignature(controller);
    }

    /**
   * @dev query public key list
   * @param did did
   */
    function getAllPubKey(string memory did)
    didActivated(did)
    public view returns (StorageUtils.PublicKey[] memory) {
        did = BytesUtils.toLower(did);
        return StorageUtils.getAllPubKey(data[did], did, StorageUtils.KEY_TYPE_ADDR);
    }

    /**
   * @dev query authentication list
   * @param did did
   */
    function getAllAuthKey(string memory did)
    didActivated(did)
    public view returns (StorageUtils.PublicKey[] memory) {
        did = BytesUtils.toLower(did);
        return StorageUtils.getAllAuthKey(data[did], did, StorageUtils.KEY_TYPE_ADDR);
    }

    /**
   * @dev query context list
   * @param did did
   */
    function getContext(string memory did)
    public view returns (string[] memory) {
        did = BytesUtils.toLower(did);
        string[] memory ctxs = new string[](data[did].context.length + 1);
        ctxs[0] = StorageUtils.DEFAULT_CONTEXT;
        for (uint i = 0; i < data[did].context.length; i++) {
            ctxs[i + 1] = data[did].context[i];
        }
        return ctxs;
    }

    /**
   * @dev query controller list
   * @param did did
   */
    function getAllController(string memory did)
    public view returns (string[] memory){
        did = BytesUtils.toLower(did);
        return data[did].controller;
    }

    /**
   * @dev query service list
   * @param did did
   */
    function getAllService(string memory did)
    public view returns (StorageUtils.Service[] memory){
        did = BytesUtils.toLower(did);
        return data[did].service;
    }

    /**
   * @dev query did updated time
   * @param did did
   */
    function getUpdatedTime(string memory did)
    public view returns (uint){
        did = BytesUtils.toLower(did);
        return data[did].updated;
    }

    /**
   * @dev query document
   * @param did did
   */
    function getDocument(string memory did)
    public view returns (StorageUtils.DIDDocument memory) {
        string[] memory context = getContext(did);
        StorageUtils.PublicKey[] memory publicKey = getAllPubKey(did);
        StorageUtils.PublicKey[] memory authentication = getAllAuthKey(did);
        string[] memory controller = getAllController(did);
        StorageUtils.Service[] memory service = getAllService(did);
        uint updated = getUpdatedTime(did);
        // always set created time as 0
        return StorageUtils.DIDDocument(context, did, publicKey, authentication, controller, service, 0, updated);
    }
}
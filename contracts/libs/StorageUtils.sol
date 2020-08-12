// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./DidUtils.sol";
import "./BytesUtils.sol";

library StorageUtils {

    string public constant KEY_TYPE_PUB = "EcdsaSecp256k1VerificationKey2019";
    string public constant KEY_TYPE_ADDR = "EcdsaSecp256k1RecoveryMethod2020";

    string public constant DEFAULT_CONTEXT = "https://www.w3.org/ns/did/v1";
    bytes32 public constant DEFAULT_CONTEXT_HASH = keccak256(bytes(DEFAULT_CONTEXT));

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

    // represent public key in did document
    struct PublicKey {
        string id; // public key id
        string keyType; // public key type, in ethereum
        string[] controller; // did array, has some permission
        bytes pubKey; // public key
        address ethAddr; // ethereum address, refer: https://www.w3.org/TR/did-spec-registries/#ethereumaddress
        bool deactivated; // is deactivated or not
        bool isPubKey; // existed in public key list or not
        bool isAuth; // existed in authentication list or not
        uint authIndex; // index at authentication list, 0 means no auth
    }

    struct Service {
        string serviceId;
        string serviceType;
        string serviceEndpoint;
    }

    function genPublicKeyFromDID(string memory did, string memory keyType) public pure returns (PublicKey memory){
        address didAddr = DidUtils.parseAddrFromDID(bytes(did));
        bytes memory id = abi.encodePacked(did, "#keys-1");
        string[] memory controller = new string[](1);
        controller[0] = did;
        bytes memory pubKey = new bytes(0);
        return PublicKey(string(id), keyType, controller, pubKey, didAddr, false, true, true, 1);
    }

    /**
   * @dev get all public key with default public addr
   * @param document document
   * @param did did
   * @param typeOfDefaultKey should be EcdsaSecp256k1RecoveryMethod2020
   */
    function getAllPubKey(DIDDocument storage document, string memory did, string memory typeOfDefaultKey)
    public view returns (PublicKey[] memory) {
        // first loop to calculate dynamic array size
        uint validKeySize = 0;
        for (uint i = 0; i < document.publicKey.length; i++) {
            if (!document.publicKey[i].deactivated && document.publicKey[i].isPubKey) {
                validKeySize++;
            }
        }
        // second loop to filter result
        PublicKey[] memory result = new PublicKey[](validKeySize + 1);
        result[0] = genPublicKeyFromDID(did, typeOfDefaultKey);
        uint count = 1;
        for (uint i = 0; i < document.publicKey.length; i++) {
            if (!document.publicKey[i].deactivated && document.publicKey[i].isPubKey) {
                result[count] = document.publicKey[i];
                count++;
            }
        }
        return result;
    }

    /**
   * @dev get all auth public key with default public addr
   * @param document document
   * @param did did
   * @param typeOfDefaultKey should be EcdsaSecp256k1RecoveryMethod2020
   */
    function getAllAuthKey(DIDDocument storage document, string memory did, string memory typeOfDefaultKey)
    public view returns (PublicKey[] memory) {
        // first loop to calculate dynamic array size
        uint authKeySize = 0;
        PublicKey[] memory allKey = new PublicKey[](document.publicKey.length);
        uint count = 0;
        for (uint i = 0; i < document.publicKey.length; i++) {
            allKey[count] = document.publicKey[i];
            if (!allKey[count].deactivated && allKey[count].isAuth && allKey[count].authIndex > 0) {
                authKeySize++;
            }
            count++;
        }
        for (uint i = 0; i < allKey.length; i++) {
            for (uint j = i + 1; j < allKey.length; j++) {
                if (allKey[i].authIndex > allKey[j].authIndex) {
                    PublicKey memory temp = allKey[i];
                    allKey[i] = allKey[j];
                    allKey[j] = temp;
                }
            }
        }
        // copy allKey to result
        PublicKey[] memory result = new PublicKey[](authKeySize + 1);
        result[0] = genPublicKeyFromDID(did, typeOfDefaultKey);
        for (uint i = 0; i < authKeySize; i++) {
            result[i + 1] = allKey[count - authKeySize + i];
        }
        return result;
    }

    function addNewPubKey(DIDDocument storage document, string memory did, bytes memory pubKey, address addr,
        string memory keyType, string[] memory controller, bool isPub, uint authIndex) internal {
        require(controller.length >= 1);
        StorageUtils.PublicKey[] storage keys = document.publicKey;
        bytes32 newHash = keccak256(abi.encodePacked(pubKey, addr));
        bool duplicated;
        for (uint i = 0; i < keys.length; i++) {
            if (newHash == keccak256(abi.encodePacked(keys[i].pubKey, keys[i].ethAddr))) {
                duplicated = true;
                break;
            }
        }
        require(!duplicated, "key already existed");
        uint keyIndex = keys.length + 2;
        string memory pubKeyId = string(abi.encodePacked(did, "#keys-", BytesUtils.uint2str(keyIndex)));
        StorageUtils.PublicKey memory pub = StorageUtils.PublicKey(pubKeyId, keyType, controller, pubKey,
            addr, false, isPub, authIndex > 0, authIndex);
        keys.push(pub);
        document.updated = now;
    }

    function authPubKey(DIDDocument storage document, bytes memory pubKey, address addr, uint authIndex)
    internal {
        StorageUtils.PublicKey[] storage keys = document.publicKey;
        bytes32 newHash = keccak256(abi.encodePacked(pubKey, addr));
        for (uint i = 0; i < keys.length; i++) {
            if (keys[i].deactivated) {
                continue;
            }
            if (newHash == keccak256(abi.encodePacked(keys[i].pubKey, keys[i].ethAddr))) {
                require(!keys[i].isAuth, "key is authenticated");
                keys[i].isAuth = true;
                keys[i].authIndex = authIndex;
                document.updated = now;
                return;
            }
        }
        require(false, "no key meet requirements");
    }

    function deactivatePubKey(DIDDocument storage document, bytes memory pubKey, address addr)
    internal {
        StorageUtils.PublicKey[] storage keys = document.publicKey;
        bytes32 newHash = keccak256(abi.encodePacked(pubKey, addr));
        for (uint i = 0; i < keys.length; i++) {
            if (newHash == keccak256(abi.encodePacked(keys[i].pubKey, keys[i].ethAddr))) {
                require(!keys[i].deactivated, "key is deactivated");
                keys[i].isPubKey = false;
                keys[i].isAuth = false;
                keys[i].deactivated = true;
                keys[i].authIndex = 0;
                document.updated = now;
                return;
            }
        }
        require(false, "no key meet requirements");
    }

    function deAuthPubKey(DIDDocument storage document, bytes memory pubKey, address addr)
    internal {
        StorageUtils.PublicKey[] storage keys = document.publicKey;
        bytes32 newHash = keccak256(abi.encodePacked(pubKey, addr));
        for (uint i = 0; i < keys.length; i++) {
            if (newHash == keccak256(abi.encodePacked(keys[i].pubKey, keys[i].ethAddr))) {
                require(!keys[i].deactivated, "key is deactivated");
                require(keys[i].isAuth, "key has already not authenticated");
                keys[i].isAuth = false;
                keys[i].authIndex = 0;
                document.updated = now;
                return;
            }
        }
        require(false, "no key meet requirements");
    }

    function addContext(DIDDocument storage document, string memory context)
    internal returns (bool) {
        bytes32 newCtxHash = keccak256(bytes(context));
        if (newCtxHash == DEFAULT_CONTEXT_HASH) {
            return false;
        }
        string[] storage oldContexts = document.context;
        for (uint j = 0; j < oldContexts.length; j++) {
            if (newCtxHash == keccak256(bytes(oldContexts[j]))) {
                return false;
            }
        }
        oldContexts.push(context);
        return true;
    }

    function removeContext(DIDDocument storage document, string memory context)
    internal returns (bool) {
        string[] storage oldContexts = document.context;
        bytes32 newCtxHash = keccak256(bytes(context));
        for (uint j = 0; j < oldContexts.length; j++) {
            if (newCtxHash == keccak256(bytes(oldContexts[j]))) {
                oldContexts[j] = oldContexts[oldContexts.length - 1];
                delete oldContexts[oldContexts.length - 1];
                oldContexts.pop();
                return true;
            }
        }
        return false;
    }

    function addController(DIDDocument storage document, string memory controller)
    internal {
        string[] storage ctrls = document.controller;
        for (uint i = 0; i < ctrls.length; i++) {
            if (BytesUtils.strEqual(controller, ctrls[i])) {
                require(false, "controller already existed");
            }
        }
        ctrls.push(controller);
    }

    function removeController(DIDDocument storage document, string memory controller)
    internal {
        string[] storage ctrls = document.controller;
        for (uint i = 0; i < ctrls.length; i++) {
            if (BytesUtils.strEqual(controller, ctrls[i])) {
                ctrls[i] = ctrls[ctrls.length - 1];
                delete ctrls[ctrls.length - 1];
                ctrls.pop();
                document.updated = now;
                return;
            }
        }
        require(false, "controller not exist");
    }

    function addService(DIDDocument storage document, string memory serviceId, string memory serviceType,
        string memory serviceEndpoint)
    internal {
        StorageUtils.Service[] storage services = document.service;
        for (uint i = 0; i < services.length; i++) {
            if (BytesUtils.strEqual(serviceId, services[i].serviceId)) {
                require(false, "service already existed");
            }
        }
        services.push(StorageUtils.Service(serviceId, serviceType, serviceEndpoint));
    }

    function updateService(DIDDocument storage document, string memory serviceId, string memory serviceType,
        string memory serviceEndpoint)
    internal {
        StorageUtils.Service[] storage services = document.service;
        for (uint i = 0; i < services.length; i++) {
            if (BytesUtils.strEqual(serviceId, services[i].serviceId)) {
                services[i].serviceType = serviceType;
                services[i].serviceEndpoint = serviceEndpoint;
                document.updated = now;
                return;
            }
        }
        require(false, "service not exist");
    }

    function removeService(DIDDocument storage document, string memory serviceId)
    internal {
        StorageUtils.Service[] storage services = document.service;
        for (uint i = 0; i < services.length; i++) {
            if (BytesUtils.strEqual(serviceId, services[i].serviceId)) {
                services[i] = services[services.length - 1];
                delete services[services.length - 1];
                services.pop();
                document.updated = now;
                return;
            }
        }
        require(false, "service not exist");
    }
}

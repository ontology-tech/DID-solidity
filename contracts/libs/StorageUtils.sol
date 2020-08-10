// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./ZeroCopySource.sol";
import "./ZeroCopySink.sol";
import "./KeyUtils.sol";
import "./IterableMapping.sol";

library StorageUtils {
    using IterableMapping for IterableMapping.itmap;

    // represent public key in did document
    struct PublicKey {
        string id; // public key id
        string keyType; // public key type, in ethereum, the type is always EcdsaSecp256k1VerificationKey2019
        string[] controller; // did array, has some permission
        bytes pubKey; // public key
        bool deactivated; // is deactivated or not
        bool isPubKey; // existed in public key list or not
        bool isAuth; // existed in authentication list or not
        uint authIndex; // index at authentication list
    }

    function serializePubKey(PublicKey memory publicKey) public pure returns (bytes memory){
        bytes memory result = new bytes(0);
        bytes memory idBytes = ZeroCopySink.WriteVarBytes(bytes(publicKey.id));
        result = abi.encodePacked(result, idBytes);
        bytes memory keyTypeBytes = ZeroCopySink.WriteVarBytes(bytes(publicKey.keyType));
        result = abi.encodePacked(result, keyTypeBytes);
        bytes memory controllerLenBytes = ZeroCopySink.WriteUint255(publicKey.controller.length);
        result = abi.encodePacked(result, controllerLenBytes);
        for (uint i = 0; i < publicKey.controller.length; i++) {
            result = abi.encodePacked(result, ZeroCopySink.WriteVarBytes(bytes(publicKey.controller[i])));
        }
        bytes memory pubKeyBytes = ZeroCopySink.WriteVarBytes(publicKey.pubKey);
        result = abi.encodePacked(result, pubKeyBytes);
        bytes memory deactivatedBytes = ZeroCopySink.WriteBool(publicKey.deactivated);
        result = abi.encodePacked(result, deactivatedBytes);
        bytes memory isPubKeyBytes = ZeroCopySink.WriteBool(publicKey.isPubKey);
        result = abi.encodePacked(result, isPubKeyBytes);
        bytes memory isAuthKeyBytes = ZeroCopySink.WriteBool(publicKey.isAuth);
        result = abi.encodePacked(result, isAuthKeyBytes);
        bytes memory authIndexBytes = ZeroCopySink.WriteUint255(publicKey.authIndex);
        result = abi.encodePacked(result, authIndexBytes);
        return result;
    }

    function deserializePubKey(bytes memory data) public pure returns (PublicKey memory){
        (bytes memory id, uint offset) = ZeroCopySource.NextVarBytes(data, 0);
        bytes memory keyType;
        (keyType, offset) = ZeroCopySource.NextVarBytes(data, offset);
        uint controllerLen;
        (controllerLen, offset) = ZeroCopySource.NextUint255(data, offset);
        string[]memory controller = new string[](controllerLen);
        for (uint i = 0; i < controllerLen; i++) {
            bytes memory ctrl;
            (ctrl, offset) = ZeroCopySource.NextVarBytes(data, offset);
            controller[i] = string(ctrl);
        }
        bytes memory pubKey;
        (pubKey, offset) = ZeroCopySource.NextVarBytes(data, offset);
        bool deactivated;
        bool isPubKey;
        bool isAuth;
        (deactivated, offset) = ZeroCopySource.NextBool(data, offset);
        (isPubKey, offset) = ZeroCopySource.NextBool(data, offset);
        (isAuth, offset) = ZeroCopySource.NextBool(data, offset);
        uint authIndex;
        (authIndex, offset) = ZeroCopySource.NextUint255(data, offset);
        return PublicKey(string(id), string(keyType), controller, pubKey, deactivated, isPubKey, isAuth, authIndex);
    }

    /**
   * @dev query public key list
   * @param pubKeyList public key list
   */
    function getAllPubKey(IterableMapping.itmap storage pubKeyList) public view returns (PublicKey[] memory) {
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
            allKey[count] = deserializePubKey(pubKeyData);
            if (!allKey[count].deactivated && allKey[count].isPubKey) {
                validKeySize++;
            }
            count++;
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
   * @param pubKeyList public key list
   */
    function getAllAuthKey(IterableMapping.itmap storage pubKeyList)
    public view returns (PublicKey[] memory) {
        // first loop to calculate dynamic array size
        uint authKeySize = 0;
        PublicKey[] memory allKey = new PublicKey[](pubKeyList.size);
        uint count = 0;
        for (
            uint i = pubKeyList.iterate_start();
            pubKeyList.iterate_valid(i);
            i = pubKeyList.iterate_next(i)
        ) {
            (, bytes memory pubKeyData) = pubKeyList.iterate_get(i);
            allKey[count] = deserializePubKey(pubKeyData);
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
        PublicKey[] memory result = new PublicKey[](authKeySize);
        for (uint i = 0; i < authKeySize; i++) {
            result[i] = allKey[count - authKeySize + i];
        }
        return result;
    }

    /**
   * @dev query context list
   * @param ctxList context list
   */
    function getContext(IterableMapping.itmap storage ctxList) public view returns (string[] memory) {
        string[] memory result = new string[](ctxList.size + 1);
        // add default context
        result[0] = "https://www.w3.org/ns/did/v1";
        uint count = 1;
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
    * @param controllerList controller list
    */
    function getAllController(IterableMapping.itmap storage controllerList)
    public view returns (string[] memory){
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

    /**
    * @dev query service list
    * @param serviceList service list
    */
    function getAllService(IterableMapping.itmap storage serviceList)
    public view returns (Service[] memory){
        Service[] memory result = new Service[](serviceList.size);
        uint count = 0;
        for (
            uint i = serviceList.iterate_start();
            serviceList.iterate_valid(i);
            i = serviceList.iterate_next(i)
        ) {
            (, bytes memory serviceData) = serviceList.iterate_get(i);
            result[count] = deserializeService(serviceData);
            count++;
        }
        return result;
    }

    struct Service {
        string serviceId;
        string serviceType;
        string serviceEndpoint;
    }

    function serializeService(Service memory service) public pure returns (bytes memory){
        bytes memory idBytes = ZeroCopySink.WriteVarBytes(bytes(service.serviceId));
        bytes memory typeBytes = ZeroCopySink.WriteVarBytes(bytes(service.serviceType));
        bytes memory endpointBytes = ZeroCopySink.WriteVarBytes(bytes(service.serviceEndpoint));
        bytes memory serviceBytes = abi.encodePacked(idBytes, typeBytes, endpointBytes);
        return serviceBytes;
    }

    function deserializeService(bytes memory serviceBytes) public pure returns (Service memory){
        (bytes memory id, uint offset) = ZeroCopySource.NextVarBytes(serviceBytes, 0);
        bytes memory serviceType = new bytes(0);
        (serviceType, offset) = ZeroCopySource.NextVarBytes(serviceBytes, offset);
        bytes memory endpoint = new bytes(0);
        (endpoint, offset) = ZeroCopySource.NextVarBytes(serviceBytes, offset);
        return Service(string(id), string(serviceType), string(endpoint));
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
}

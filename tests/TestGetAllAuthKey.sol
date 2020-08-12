// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "../contracts/libs/StorageUtils.sol";
import "../contracts/libs/IterableMapping.sol";

contract TestGetAllAuthKey {
    using IterableMapping for IterableMapping.itmap;

    IterableMapping.itmap public pubKeyListData;

    function beforeEach() public {
        string memory pubKeyId = string(abi.encodePacked("did", "#keys-1"));
        string[] memory defaultController = new string[](1);
        defaultController[0] = "did";
        bytes memory pubKey = new bytes(0);
        StorageUtils.PublicKey memory pub = StorageUtils.PublicKey(pubKeyId, "PUB_KEY_TYPE", defaultController, pubKey,
            address(0), false, true, true, 0);
        pubKeyListData.insert(keccak256(bytes("1")), StorageUtils.serializePubKey(pub));
        pub.authIndex = 4;
        pubKeyListData.insert(keccak256(bytes("2")), StorageUtils.serializePubKey(pub));
        pub.authIndex = 3;
        pubKeyListData.insert(keccak256(bytes("3")), StorageUtils.serializePubKey(pub));
        pub.authIndex = 0;
        pubKeyListData.insert(keccak256(bytes("4")), StorageUtils.serializePubKey(pub));
        pub.authIndex = 5;
        pubKeyListData.insert(keccak256(bytes("5")), StorageUtils.serializePubKey(pub));
        pub.authIndex = 2;
        pubKeyListData.insert(keccak256(bytes("6")), StorageUtils.serializePubKey(pub));
        pub.authIndex = 7;
        pubKeyListData.insert(keccak256(bytes("7")), StorageUtils.serializePubKey(pub));
        pub.authIndex = 0;
        pubKeyListData.insert(keccak256(bytes("8")), StorageUtils.serializePubKey(pub));
        pub.authIndex = 10;
        pubKeyListData.insert(keccak256(bytes("9")), StorageUtils.serializePubKey(pub));
    }

    function testGetAllAuthKey() public {
        StorageUtils.PublicKey[] memory allKeys = StorageUtils.getAllAuthKey("", "", pubKeyListData);
        require(allKeys.length == 7, 'length not equal');
        require(allKeys[0].authIndex == 1, '0 not equal');
        require(allKeys[1].authIndex == 2, '1 not equal');
        require(allKeys[2].authIndex == 3, '2 not equal');
        require(allKeys[3].authIndex == 4, '3 not equal');
        require(allKeys[4].authIndex == 5, '4 not equal');
        require(allKeys[5].authIndex == 7, '5 not equal');
        require(allKeys[6].authIndex == 10, '6 not equal');
    }
}

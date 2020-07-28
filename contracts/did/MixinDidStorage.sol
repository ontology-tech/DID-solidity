// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.6.0;

import "../libs/IterableMapping.sol";

/**
 * @title MixinDidStorage
 * @dev This contract is did storage implementation
 */
contract MixinDidStorage {
    using IterableMapping for IterableMapping.itmap;
    mapping(string => IterableMapping.itmap) public data; // data storage

    byte public constant ACTIVATED = "1";
    byte public constant REVOKED = "0";

    string public constant PUB_KEY_TYPE = "EcdsaSecp256k1VerificationKey2019";
}
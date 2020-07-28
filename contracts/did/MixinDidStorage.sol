// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.6.0;

import "../libs/IterableMapping.sol";


contract MixinDidStorage {
    using IterableMapping for IterableMapping.itmap;
    mapping(string => IterableMapping.itmap) public data;

    byte public constant ACTIVATED = "1";
    byte public constant REVOKED = "0";

    string public constant PUB_KEY_TYPE = "EcdsaSecp256k1VerificationKey2019";
}
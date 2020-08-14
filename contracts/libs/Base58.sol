// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity 0.5.6;

// TODO: remove this file
library Base58 {

    bytes constant ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

    function toBase58(bytes memory source) internal pure returns (bytes memory) {
        if (source.length == 0) return new bytes(0);
        uint8[] memory digits = new uint8[](40);
        //TODO: figure out exactly how much is needed
        digits[0] = 0;
        uint8 digitlength = 1;
        for (uint i = 0; i < source.length; ++i) {
            uint carry = uint8(source[i]);
            for (uint j = 0; j < digitlength; ++j) {
                carry += uint(digits[j]) * 256;
                digits[j] = uint8(carry % 58);
                carry = carry / 58;
            }

            while (carry > 0) {
                digits[digitlength] = uint8(carry % 58);
                digitlength++;
                carry = carry / 58;
            }
        }
        //return digits;
        return toAlphabet(reverse(truncate(digits, digitlength)));
    }

    function toAlphabet(uint8[] memory indices) internal pure returns (bytes memory) {
        bytes memory output = new bytes(indices.length);
        for (uint i = 0; i < indices.length; i++) {
            output[i] = ALPHABET[indices[i]];
        }
        return output;
    }

    function truncate(uint8[] memory array, uint8 length) internal pure returns (uint8[] memory) {
        uint8[] memory output = new uint8[](length);
        for (uint i = 0; i < length; i++) {
            output[i] = array[i];
        }
        return output;
    }

    function reverse(uint8[] memory input) internal pure returns (uint8[] memory) {
        uint8[] memory output = new uint8[](input.length);
        for (uint i = 0; i < input.length; i++) {
            output[i] = input[input.length - 1 - i];
        }
        return output;
    }
}

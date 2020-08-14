// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity 0.5.6;

import './Proxy.sol';
import './UpgradeabilityStorage.sol';

/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {
    /**
    * @dev This event will be emitted every time the implementation gets upgraded
    * @param version representing the version name of the upgraded implementation
    * @param implementation representing the address of the upgraded implementation
    */
    event Upgraded(string version, address indexed implementation);

    /**
    * @dev Tells the address of the current implementation
    * @return address of the current implementation
    */
    function implementation() public view returns (address) {
        return _implementation;
    }

    /**
    * @dev Upgrades the implementation address
    * @param version representing the version name of the new implementation to be set
    * @param impl representing the address of the new implementation to be set
    */
    function _upgradeTo(string memory version, address impl) internal {
        require(_implementation != impl);
        _version = version;
        _implementation = impl;
        emit Upgraded(version, impl);
    }
}

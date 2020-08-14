// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity 0.5.6;

import "../did/MixinDidStorage.sol";
import "./OwnedUpgradeabilityProxy.sol";

contract EternalStorageProxy is MixinDidStorage, OwnedUpgradeabilityProxy {}

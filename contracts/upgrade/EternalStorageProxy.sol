pragma solidity ^0.4.0;

import "../did/MixinDidStorage.sol";
import "./OwnedUpgradeabilityProxy.sol";

contract EternalStorageProxy is MixinDidStorage, OwnedUpgradeabilityProxy {}

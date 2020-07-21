pragma solidity >=0.6.0 <0.7.0;

import "../did/MixinDidStorage.sol";
import "./OwnedUpgradeabilityProxy.sol";

contract EternalStorageProxy is MixinDidStorage, OwnedUpgradeabilityProxy {}

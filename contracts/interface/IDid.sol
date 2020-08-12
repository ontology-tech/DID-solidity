// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;


// define the interface and event of Did in this interface
interface IDid {

    event Deactivate(string did);

    function deactivateID(string calldata did) external;


    event AddKey(string did, bytes pubKey, string[] controller);

    function addKey(string calldata did, bytes calldata newPubKey, string[] calldata pubKeyController) external;

    event AddAddr(string did, address addr, string[] controller);

    function addAddr(string calldata did, address addr, string[] calldata pubKeyController) external;


    event DeactivateKey(string did, bytes pubKey);

    function deactivateKey(string calldata did, bytes calldata pubKey) external;

    event DeactivateAddr(string did, address addr);

    function deactivateAddr(string calldata did, address addr) external;


    event AddNewAuthKey(string did, bytes pubKey, string[] controller);

    function addNewAuthKey(string calldata did, bytes calldata pubKey, string[] calldata controller) external;

    function addNewAuthKeyByController(string calldata did, bytes calldata pubKey, string[] calldata controller, string calldata controllerSigner) external;

    event AddNewAuthAddr(string did, address addr, string[] controller);

    function addNewAuthAddr(string calldata did, address addr, string[] calldata controller) external;

    function addNewAuthAddrByController(string calldata did, address addr, string[] calldata controller, string calldata controllerSigner) external;


    event SetAuthKey(string did, bytes pubKey);

    function setAuthKey(string calldata did, bytes calldata pubKey) external;

    function setAuthKeyByController(string calldata did, bytes calldata pubKey, string calldata controller) external;

    event SetAuthAddr(string did, address addr);

    function setAuthAddr(string calldata did, address addr) external;

    function setAuthAddrByController(string calldata did, address addr, string calldata controller) external;


    event DeactivateAuthKey(string did, bytes pubKey);

    function deactivateAuthKey(string calldata did, bytes calldata pubKey) external;

    function deactivateAuthKeyByController(string calldata did, bytes calldata pubKey, string calldata controller) external;

    event DeactivateAuthAddr(string did, address addr);

    function deactivateAuthAddr(string calldata did, address addr) external;

    function deactivateAuthAddrByController(string calldata did, address addr, string calldata controller) external;


    event AddContext(string did, string context);

    function addContext(string calldata did, string[] calldata context) external;


    event RemoveContext(string did, string context);

    function removeContext(string calldata did, string[] calldata context) external;


    event AddService(string did, string serviceId, string serviceType, string serviceEndpoint);

    function addService(string calldata did, string calldata serviceId, string calldata serviceType, string calldata serviceEndpoint) external;


    event UpdateService(string did, string serviceId, string serviceType, string serviceEndpoint);

    function updateService(string calldata did, string calldata serviceId, string calldata serviceType, string calldata serviceEndpoint) external;


    event RemoveService(string did, string serviceId);

    function removeService(string calldata did, string calldata serviceId) external;


    event AddController(string did, string controller);

    function addController(string calldata did, string calldata controller) external;


    event RemoveController(string did, string controller);

    function removeController(string calldata did, string calldata controller) external;
}
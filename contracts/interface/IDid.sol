pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;


// define the interface of Did in this interface
interface IDid {
    event Register(string indexed did);

    function regIDWithPublicKey(string calldata did, bytes calldata pubKey) external;


    event DeActive(string indexed did);

    function deActiveID(string calldata did) external;


    event AddKey(string indexed did, bytes pubKey, string[] controller);

    function addKey(string calldata did, bytes calldata newPubKey, string[] calldata pubKeyController) external;


    event DeActiveKey(string indexed did, bytes pubKey);

    function deActiveKey(string calldata did, bytes calldata pubKey) external;


    event AddNewAuthKey(string indexed did, bytes pubKey, string[] controller);

    function addNewAuthKey(string calldata did, bytes calldata pubKey, string[] calldata controller) external;

    function addNewAuthKeyByController(string calldata did, bytes calldata pubKey, string[] calldata controller, string calldata controllerSigner) external;


    event SetAuthKey(string indexed did, bytes pubKey);

    function setAuthKey(string calldata did, bytes calldata pubKey) external;

    function setAuthKeyByController(string calldata did, bytes calldata pubKey, string calldata controller) external;


    event DeActiveAuthKey(string indexed did, bytes pubKey);

    function deActiveAuthKey(string calldata did, bytes calldata pubKey) external;

    function deActiveAuthKeyByController(string calldata did, bytes calldata pubKey, string calldata controller) external;


    event AddContext(string indexed did, string context);

    function addContext(string calldata did, string[] calldata context) external;


    event RemoveContext(string indexed did, string context);

    function removeContext(string calldata did, string[] calldata context) external;


    function addService(string did, string serviceId, string serviceType, string serviceEndpoint) external;

    function addServiceByController(string did, string controller, string serviceId, string serviceType, string serviceEndpoint) external;

    function updateService(string did, string serviceId, string serviceType, string serviceEndpoint) external;

    function updateServiceByController(string did, string controller, string serviceId, string serviceType, string serviceEndpoint) external;

    function removeService(string did, string serviceId) external;

    function removeServiceByController(string did, string serviceId, string controller) external;

    function addController(string did, string controller) external;

    function addControllerByController(string did, string controller, string controllerSigner) external;

    function removeController(string did, string controller) external;

    function removeControllerByController(string did, string controller, string signer) external;
}
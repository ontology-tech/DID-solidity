pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;


// define the interface of Did in this interface
interface IDid {
    event Register(string indexed did);

    function regIDWithPublicKey(string calldata did, bytes calldata pubKey) external;


    event Deactivate(string indexed did);

    function deactivateID(string calldata did) external;


    event AddKey(string indexed did, bytes pubKey, string[] controller);

    function addKey(string calldata did, bytes calldata newPubKey, string[] calldata pubKeyController) external;


    event DeactivateKey(string indexed did, bytes pubKey);

    function deactivateKey(string calldata did, bytes calldata pubKey) external;


    event AddNewAuthKey(string indexed did, bytes pubKey, string[] controller);

    function addNewAuthKey(string calldata did, bytes calldata pubKey, string[] calldata controller) external;

    function addNewAuthKeyByController(string calldata did, bytes calldata pubKey, string[] calldata controller, string calldata controllerSigner) external;


    event SetAuthKey(string indexed did, bytes pubKey);

    function setAuthKey(string calldata did, bytes calldata pubKey) external;

    function setAuthKeyByController(string calldata did, bytes calldata pubKey, string calldata controller) external;


    event DeactivateAuthKey(string indexed did, bytes pubKey);

    function deactivateAuthKey(string calldata did, bytes calldata pubKey) external;

    function deactivateAuthKeyByController(string calldata did, bytes calldata pubKey, string calldata controller) external;


    event AddContext(string indexed did, string context);

    function addContext(string calldata did, string[] calldata context) external;


    event RemoveContext(string indexed did, string context);

    function removeContext(string calldata did, string[] calldata context) external;


    event AddService(string indexed did, string serviceId, string serviceType, string serviceEndpoint);
    event UpdateService(string indexed did, string serviceId, string serviceType, string serviceEndpoint);
    event RemoveService(string indexed did, string serviceId);

    function addService(string calldata did, string calldata serviceId, string calldata serviceType, string calldata serviceEndpoint) external;

    function updateService(string calldata did, string calldata serviceId, string calldata serviceType, string calldata serviceEndpoint) external;

    function removeService(string calldata did, string calldata serviceId) external;

    event AddController(string indexed did, string controller);
    event RemoveController(string indexed did, string controller);


    function addController(string calldata did, string calldata controller) external;

    function removeController(string calldata did, string calldata controller) external;

    function VerifyController(string calldata did, string calldata controller) external returns (bool);
}
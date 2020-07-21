pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;


// define the interface of Did in this interface
interface IDid {

    event Register(string indexed did);

    function regIDWithPublicKey(string calldata did, bytes calldata pubKey) external;

    // function regIDWithController(string calldata did, string[] calldata controller, string calldata signerDID) external;


    event Revoke(string indexed did);

    function revokeID(string calldata did) external;

    // function revokeIDByController(string calldata did, string calldata controllerSigner) external;


    event AddController(string indexed did, string controller);

    function addController(string calldata did, string calldata controller) external;

    // function addControllerByController(string calldata did, string calldata controller, string calldata controllerSigner) external;


    event RemoveController(string indexed did, string controller);

    function removeController(string calldata did, string calldata controller) external;

    // function removeControllerByController(string calldata did, string calldata controller, string calldata controllerSigner) external;


    event AddKey(string indexed did, bytes pubKey, string[] controller);

    function addKey(string calldata did, bytes calldata newPubKey, string[] calldata pubKeyController) external;

    // function addKeyByController(string calldata did, string calldata controller, bytes calldata newPubKey, string[] calldata pubKeyController) external;


    event RemoveKey(string indexed did, bytes pubKey);

    function removeKey(string calldata did, bytes calldata pubKey) external;

    // function removeKeyByController(string calldata did, bytes calldata pubKey, bytes calldata controller) external;


    event AddNewAuthKey(string indexed did, bytes pubKey, string[] controller);

    function addNewAuthKey(string calldata did, bytes calldata pubKey, string[] calldata controller) external;

    function addNewAuthKeyByController(string calldata did, bytes calldata pubKey, string[] calldata controller, string calldata controllerSigner) external;


    event SetAuthKey(string indexed did, bytes pubKey);

    function setAuthKey(string calldata did, bytes calldata pubKey) external;

    function setAuthKeyByController(string calldata did, bytes calldata pubKey, string calldata controller) external;


    event RemoveAuthKey(string indexed did, bytes pubKey);

    function removeAuthKey(string calldata did, bytes calldata pubKey) external;

    function removeAuthKeyByController(string calldata did, bytes calldata pubKey, string calldata controller) external;


    event AddContext(string indexed did, string context);

    function addContext(string calldata did, string[] calldata context) external;

    // function addContextByController(string calldata did, string[] calldata context, string calldata controller) external;


    event RemoveContext(string indexed did, string context);

    function removeContext(string calldata did, string[] calldata context) external;

    // function removeContextByController(string calldata did, string[] calldata context, string calldata controller) external;

    function addService(string did, string serviceId, string serviceType, string serviceEndpoint)
    external
    returns (bool ok);

    function addServiceByController(string did, string controller, string serviceId, string serviceType, string serviceEndpoint)
    external
    returns (bool ok);

    function updateService(string did, string serviceId, string serviceType, string serviceEndpoint)
    external
    returns (bool ok);

    function updateServiceByController(string did, string controller, string serviceId, string serviceType, string serviceEndpoint)
    external
    returns (bool ok);

    function removeService(string did, string serviceId)
    external
    returns (bool ok);

    function removeServiceByController(string did, string serviceId, string controller)
    external
    returns (bool ok);

    function addController(string did, string controller)
    external
    returns (bool ok);

    function addControllerByController(string id, string controller, string controllerSigner)
    external
    returns (bool ok);

    function removeController(string id, string controller)
    external
    returns (bool ok);

    function removeControllerByController(string id, string controller, string signer)
    external
    returns (bool ok);
}
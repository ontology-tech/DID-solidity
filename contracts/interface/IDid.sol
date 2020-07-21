pragma solidity ^0.6.0;

interface IDid {
    // define the interface of Did in this interface
    function regIdWithPublicKey(uint32 operatorShare, bool addOperatorAsMaker)
    external
    returns (bytes32 poolId);

    function addService(bytes id, bytes serviceId, bytes type, bytes serviceEndpoint, uint32 index)
    external
    returns (bool ok);

    function updateService(bytes id, bytes serviceId, bytes type, bytes serviceEndpoint, uint32 index)
    external
    returns (bool ok);

    function removeService(bytes id, bytes serviceId, uint32 index)
    external
    returns (bool ok);

    function regIdWithController(bytes ownerId, bytes controllerId, uint32 index)
    external
    returns (bool ok);

    function revokeIDByController(bytes id, uit32 index)
    external
    returns (bool ok);
    
}
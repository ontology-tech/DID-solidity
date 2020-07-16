parama solidity ^0.6.0;

interface IDid {
    // define the interface of Did in this interface
    function regIdWithPublicKey(uint32 operatorShare, bool addOperatorAsMaker)
        external
        returns (bytes32 poolId);
}
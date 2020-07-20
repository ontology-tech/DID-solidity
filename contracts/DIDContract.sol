pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./ContentContract.sol";

abstract contract DIDContract {
    event Register(string indexed did);
    event Revoke(string indexed did);

    mapping(string => ContentContract) public contents;

    /// 为Document添加字段
    /// @param contentKey 字段名字
    /// @param contentContract
    function setContent(string memory contentKey, address contentContract) public;

    /// 移除某个字段
    /// @param contentKey
    function removeContent(string memory contentKey) public;

    function regIDWithPublicKey(string memory did, bytes32 memory pubKey) public;

    ///
    /// @param did
    /// @param controller 序列化的控制人，可以是一个group或者是一个DID
    /// @param signer 如果controller是一个DID，则signer是序列化好的签名的公钥的index；如果controller是一个group，则signer是序列化好
    /// 的所有签名人DID
    /// @param signature controller的签名
    function regIDWithController(string memory did, bytes memory controller, bytes memory signer, bytes[] memory signature) public;

    ///
    /// @param did
    /// @param index 签名的公钥的index
    function revokeID(string memory did, uint index) public;

    ///
    /// @param did
    /// @param signer 序列化的签名人数组
    /// @param signature controller的签名
    function revokeIDByController(string memory did, bytes memory signer, bytes memory signer);
}
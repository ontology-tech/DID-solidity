# DID-Ethereum-solidity 设计文档

## 当前DID的document结构

```json
{
  "@context": ["https://www.w3.org/ns/did/v1", "https://ontid.ont.io/did/v2"],
  "id": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72",
  "publicKey": [{...}],
  "authentication": [{...}],
  "controller": [...],
  "service": [{...}],
  "created": {...},
  "updated": {...}
}
```

## 三层合约体系

![image](../structure.png)

参考：https://blog.openzeppelin.com/proxy-patterns/

### Layer 1

代理层，将合约调用代理到协议层。

使用代理的好处是合约可升级，且用户入口的合约地址不变，主要依赖delegatecall实现。

### Layer 2

协议层（逻辑层），这层实现了W3C的DID协议，并且逻辑可以更改。

不存储自己的状态变量，只使用Layer 3的存储，以避免升级后的存储冲突。

### Layer 3

数据存储层，使用iterable map存储数据。数据的存储格式为bytes，序列化方式为Ontology ZeroCopy。

```solidity
contract DataContract {
    mapping(string => IterableMapping.itmap) public data; // data storage
    ...
}
```

## 合约升级

由于数据和协议相分离，所以有升级需要时，直接修改Layer 2的合约即可。Layer 3的数据存储形式直接就是K-V结构，这是与协议无关的，所以升级时无修改动。

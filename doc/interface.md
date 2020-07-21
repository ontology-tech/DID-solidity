# ONT ID Interface of Solidity Version

##  DIDContract

DIDContract 的接口分成三部分：
1. 更新DID Document字段；
2. 更新DID Document字段的数据；
3. 权限控制和升级的部分；

### 更新DID Document字段

W3C对DID协议的更新可能会涉及到整个Document字段的变迁，所以需要以接口的形式来灵活地适应这种可能的情况。

#### setContent

可以用来修改Document的字段，包括增加及修改。
```
/// 为Document添加字段
/// @param contentKey 字段名字
/// @param contentContract 对应的字段管理合约的地址
function setContent(string memory contentKey, address contentContract) public
```

#### removeContent

移除某个字段
```
/// 移除某个字段
/// @param contentKey
function removeContent(string memory contentKey) public;
```

### 更新DID Document字段的数据

这一批接口专门用来更新字段的具体数据。

[did-api](./did-api.md)

## DataContract

数据存储层必须要能存取结构体数组。

为了防止W3C协议升级改变结构体字段从而影响已有数据，存储的值必须要是序列化好的结构体数据（bytes）；
为了防止每次更新都要读写整个的数组，存储的形式将采用map实现；
为了访问数据方便，我们需要使用[iterable map](https://solidity.readthedocs.io/en/v0.6.11/types.html#iterable-mappings);

所以数据合约的存储结构应该是
```solidity
mapping(string => itmap ) public data;
```
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


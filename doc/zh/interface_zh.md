# DID-Ethereum-solidity 接口文档

### 注销DID

deactivateID

参数：

编号 |  名称 | 类型   | 说明
----|-------|---|-------
 0  |  did | string  | 注销的DID
 1  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

event:

event Deactivate(string indexed did);

### 授权操作

#### 增加代理人

addController

参数:

| 编号 | 名称 | 类型   | 说明       |
| ---- | ----| --- | ---------- |
| 0    | did | string | DID     |
| 1    | controller | string | 代理控制人 |
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

增加代理人，调用此接口需由DID的某个具有Authentication权限的公钥对应的私钥签名。

event:

event AddController(string indexed did, string controller);

#### 撤销代理人

removeController

参数:

| 编号 | 名称 | 类型   | 说明       |
| ---- | ----|--- | ---------- |
| 0    | did | string | DID     |
| 1    | controller | string | 要移除的代理控制人 |
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

移除代理人，调用此接口需由DID的某个具有Authentication权限的公钥对应的私钥签名。

event:

event RemoveController(string indexed did, string controller);

### 公钥操作

#### 添加公钥

addKey

参数：

编号 |   名称 | 类型   | 说明
----|--------|---|-------
 0  |  did | string  | DID
 1  |  newPubKey | bytes  | 添加的新公钥
 2  |  pubKeyController | string[]  | 公钥的controller（可选，默认为本ID）（新增）
 3  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

添加一把新公钥，该公钥不会拥有Authentication权限，调用此接口需由DID的某个具有Authentication权限的公钥对应的私钥签名。

event:

event AddKey(string indexed did, bytes pubKey, string[] controller);

#### 添加地址

addAddr

参数：

编号 |   名称 | 类型   | 说明
----|--------|---|-------
 0  |  did | string  | DID
 1  |  addr | address  | 添加的新地址
 2  |  pubKeyController | string[]  | 公钥的controller（可选，默认为本ID）（新增）
 3  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

event:

event AddAddr(string indexed did, address addr, string[] controller);

#### 废除公钥

deactivateKey

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
 0  |  did | string  | DID
 1  |  pubKey | bytes  | 废除的公钥
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

废除一把公钥，调用此接口需由DID的某个具有Authentication权限的公钥对应的私钥签名。

event:

event DeactivateKey(string indexed did, bytes pubKey);

#### 废除地址

deactivateAddr

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
 0  |  did | string  | DID
 1  |  addr | address  | 废除的地址
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

event:

event DeactivateAddr(string indexed did, address addr);

### 认证公钥操作

#### 添加新认证公钥

addNewAuthKey

参数：

编号 |   名称 |  类型   | 说明
----|-------| ---|-------
 0  |  did |  string | DID
 1  |  pubKey | bytes  | 公钥
 2  | controller | string[] | 公钥控制人
 3  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

添加一把新公钥，并且使其具有Authentication权限。

event:

event AddNewAuthKey(string indexed did, bytes pubKey, string[] controller);

#### 添加新认证地址

addNewAuthAddr

参数：

编号 |   名称 |  类型   | 说明
----|-------| ---|-------
 0  |  did |  string | DID
 1  |  addr | address  | 地址
 2  | controller | string[] | 地址控制人
 3  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

event:

event AddNewAuthAddr(string indexed did, address addr, string[] controller);

#### 添加新认证公钥

addNewAuthKeyByController

参数：

| 编号 |  名称 | 类型   | 说明       |
| ---- | ------| --- | ---------- |
| 0    | did | string | DID     |
| 1  |  pubKey | bytes  | 公钥 |
| 2  | controller | string[] | 公钥控制人 |
| 3    | controllerSigner | string | 签名控制人 |
 4  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

新公钥成功添加后，会自动分配一个公钥编号。

event:

event AddNewAuthKey(string indexed did, bytes pubKey, string[] controller);

#### 添加新认证地址

addNewAuthAddrByController

参数：

| 编号 |  名称 | 类型   | 说明       |
| ---- | ------| --- | ---------- |
| 0    | did | string | DID     |
| 1  |  addr | address  | 地址 |
| 2  | controller | string[] | 地址控制人 |
| 3    | controllerSigner | string | 签名控制人 |
 4  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

event:

event AddNewAuthAddr(string indexed did, addr address, string[] controller);

#### 指定认证公钥

setAuthKey

参数：

| 编号 | 名称 | 类型   | 说明       |
| ---- | -----| --- | ---------- |
| 0    | did | string | DID     |
| 1    | pubKey | bytes | 指定的公钥 |
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

使公钥列表里的一个pubkey具有权限。

event:

event SetAuthKey(string indexed did, bytes pubKey);

#### 指定认证地址

setAuthAddr

参数：

| 编号 | 名称 | 类型   | 说明       |
| ---- | -----| --- | ---------- |
| 0    | did | string | DID     |
| 1    | addr | address | 指定的地址 |
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

event:

event SetAuthAddr(string indexed did, address addr);

#### 指定认证公钥

setAuthKeyByController

参数：

| 编号 | 名称 |  类型   | 说明       |
| ---- | ------| --- | ---------- |
| 0    | did | string | DID     |
| 1    | pubKey | bytes | 指定的公钥 |
| 2    | controller | string | 签名控制人 |
 3  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

event:

event SetAuthKey(string indexed did, bytes pubKey);

#### 指定认证地址

setAuthAddrByController

参数：

| 编号 | 名称 |  类型   | 说明       |
| ---- | ------| --- | ---------- |
| 0    | did | string | DID     |
| 1    | addr | address | 指定的地址 |
| 2    | controller | string | 签名控制人 |
 3  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

event:

event SetAuthKey(string indexed did, bytes pubKey);

#### 删除认证公钥

deactivateAuthKey

参数：

编号 |  名称 | 类型   | 说明
----|--------| ---|-------
 0  |  did | string  | DID
 1  | pubKey | bytes | 删除的公钥
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |
 
 event:
 
 event DeactivateAuthKey(string indexed did, bytes pubKey); 
 
#### 删除认证地址

deactivateAuthAddr

参数：

编号 |  名称 | 类型   | 说明
----|--------| ---|-------
 0  |  did | string  | DID
 1  | addr | address | 删除的地址
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |
 
 event:
 
 event DeactivateAuthAddr(string indexed did, address addr); 

#### 删除认证公钥

deactivateAuthKeyByController

参数：

| 编号 |  名称 | 类型   | 说明       |
| ---- | ------ | --- |-------- |
| 0    | did | string | DID     |
| 1    | pubKey | bytes | 删除的公钥 |
| 2    | controller | string | 签名控制人 |
 3  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

event:
 
event DeactivateAuthKey(string indexed did, bytes pubKey);

#### 删除认证公钥

deactivateAuthAddrByController

参数：

| 编号 |  名称 | 类型   | 说明       |
| ---- | ------ | --- |-------- |
| 0    | did | string | DID     |
| 1    | addr | address | 删除的地址 |
| 2    | controller | string | 签名控制人 |
 3  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

event:
 
event DeactivateAuthAddr(string indexed did, addr address);

### 服务操作

#### 添加服务

addService

参数：

编号 |  名称 | 类型   | 说明
----|-------| ---|-------
 0  |  did | string  | DID
 1  |  serviceId | string  | 服务标识
 2  |  serviceType | string  | 服务类型
 3 | serviceEndpoint | string | service endpoint
 4  | signer | bytes | 交易的签名人，地址或者公钥都支持 |
 
 event:
 
 event AddService(string indexed did, string serviceId, string serviceType, string serviceEndpoint);

#### 更新服务

updateService

参数：

编号 |  名称 | 类型   | 说明
----|--------| ---|-------
 0  |  did | string  | DID
 1  |  serviceId | string  | 服务标识
 2  |  serviceType | string  | 服务类型
 3 | serviceEndpoint | string | service endpoint
 4  | signer | bytes | 交易的签名人，地址或者公钥都支持 |
 
 event:
 
 event UpdateService(string indexed did, string serviceId, string serviceType, string serviceEndpoint);

#### 删除服务

removeService

参数：

编号 |  名称 | 类型   | 说明
----|-------| ---|-------
 0  |  did | string  | DID
 1  |  serviceId | string  | 服务标识
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |
 
 event:
 
 event RemoveService(string indexed did, string serviceId);

### Context操作

#### 添加自定义context

addContext

参数：

编号 |  名称 | 类型   | 说明
----|-------| ---|-------
 0  |  did | string  | DID
 1  | contexts | string[] | 添加的context列表
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

若列表中的某项context已在该DID中，则忽略该项。

event:

event AddContext(string indexed did, string context);

#### 移除自定义context

removeContext

参数：

编号 |  名称 | 类型   | 说明
----|-------| ---|-------
 0  |  did | string  | DID
 1  | contexts | string[] | 要移除的context列表
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

若列表中的某项context不在该DID中，将被忽略。

event:

event RemoveContext(string indexed did, string context);

### 验证方法

#### 验证签名

verifySignature

参数：

编号 |  名称 | 类型   | 说明
----|-------| ---|-------
 0  |  did | string  | DID
 1  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

返回：True/False

#### 验证控制人签名

verifyController

参数：

编号 |  名称 | 类型   | 说明
----|--------|---|-------
 0  |  did | string | DID
 1  |  controller | string  | 签名控制人 
 2  | signer | bytes | 交易的签名人，地址或者公钥都支持 |

调用接口的交易需包含所有被验证的签名。

返回：True/False

### 查询接口

#### 查询DID Document(JSON)

>note: 此接口暂未实现

getDocumentJson

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
0  | did | string | 查询的DID

返回：DID对应的Document数据，该数据以JSON-LD方式组织。

#### 查询DID Document

getDocument

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
0  | did | string | 查询的DID

返回：DID Document。

```solidity
    struct DIDDocument {
        string[] context;
        string id;
        PublicKey[] publicKey;
        PublicKey[] authentication;
        string[] controller;
        Service[] service;
        uint created;
        uint updated;
    }
```

#### 查询context

getContext

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
0  | did | string | 查询的DID

返回：[]string

#### 查询public key列表

getAllPubKey

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
0  | did | string | 查询的DID

返回：[]PublicKey

```solidity
    struct PublicKey {
        string id; // public key id
        string keyType; // public key type, in ethereum, the type is always EcdsaSecp256k1VerificationKey2019
        string[] controller; // did array, has some permission
        bytes pubKey; // public key
        bool deactivated; // is deactivated or not
        bool isPubKey; // existed in public key list or not
        bool isAuth; // existed in authentication list or not
    }
```

#### 查询authentication列表

getAllAuthKey

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
0  | did | string | 查询的DID

返回：[]PublicKey

#### 查询controller列表

getAllController

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
0  | did | string | 查询的DID

返回：[]string

#### 查询service列表

getAllService

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
0  | did | string | 查询的DID

返回：[]Service

```solidity
    struct Service {
        string serviceId;
        string serviceType;
        string serviceEndpoint;
    }
```

#### 查询创建时间

getCreatedTime

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
0  | did | string | 查询的DID

返回：uint

#### 查询更新时间

getUpdatedTime

参数：

编号 | 名称 | 类型   | 说明
----|-----|----|-------
0  | did | string | 查询的DID

返回：uint

# DID-Celo-solidity Interface Document

### Deactivate DID

deactivateID

Param:

Num |  Name | Type   | Desc
----|-------|---|-------
 0  |  did | string  | DID
 1  |  signer | bytes  | public key or address, who sign for this transaction |

event:

event Deactivate(string did);

### Authorized Operation

#### Add Controller

addController

Param:

| Num | Name | Type   | Desc       |
| ---- | ----| --- | ---------- |
| 0    | did | string | DID     |
| 1    | controller | string |  |
 2  |  signer | bytes  | public key or address, who sign for this transaction |

Add a controller, calling this interface needs to be signed by the private key corresponding
to the public key with authentication authority of did.

event:

event AddController(string did, string controller);

#### Remove Controller

removeController

参数:

| Num | Name | Type   | Desc       |
| ---- | ----|--- | ---------- |
| 0    | did | string | DID     |
| 1    | controller | string |  |
 2  |  signer | bytes  | public key or address, who sign for this transaction |

Remove a controller, calling this interface needs to be signed by the private key corresponding
to the public key with authentication authority of did.

event:

event RemoveController(string did, string controller);

### Public Key Operation

#### Add Public Key

addKey

Param:

Num |   Name | Type   | Desc
----|--------|---|-------
 0  |  did | string  | DID
 1  |  newPubKey | bytes  | new public key
 2  |  pubKeyController | string[]  | controller of new public key（optional，default is self did）
 3  |  signer | bytes  | public key or address, who sign for this transaction |

Add a new public key that doesn't own Authentication permission, calling this interface needs to be signed by the
private key corresponding to the public key with authentication authority of did.

event:

event AddKey(string did, bytes pubKey, string[] controller);

#### Add Address

addAddr

Param:

Num |   Name | Type   | Desc
----|--------|---|-------
 0  |  did | string  | DID
 1  |  addr | address  | new address
 2  |  pubKeyController | string[]  | controller of new public key（optional，default is self did）
 3  |  signer | bytes  | public key or address, who sign for this transaction |

event:

event AddAddr(string did, address addr, string[] controller);

#### Deactivate Public Key

deactivateKey

Param:

Num | Name | Type   | Desc
----|-----|----|-------
 0  |  did | string  | DID
 1  |  pubKey | bytes  | 
 2  |  signer | bytes  | public key or address, who sign for this transaction |

Deactivate a public key, calling this interface needs to be signed by the
private key corresponding to the public key with authentication authority of did.

event:

event DeactivateKey(string did, bytes pubKey);

#### Deactivate Address

deactivateAddr

Param:

Num | Name | Type   | Desc
----|-----|----|-------
 0  |  did | string  | DID
 1  |  addr | address  | 
 2  |  signer | bytes  | public key or address, who sign for this transaction |

event:

event DeactivateAddr(string did, bytes pubKey);

### Authorized Public Key

#### Add New Authentication Key

addNewAuthKey

Param:

Num |   Name |  Type   | Desc
----|-------| ---|-------
 0  |  did |  string | DID
 1  |  pubKey | bytes  | 
 2  | controller | string[] | controller of public key
 3  |  signer | bytes  | public key or address, who sign for this transaction |

Add a new public key, the key will own authentication permission.

event:

event AddNewAuthKey(string did, address addr, string[] controller);

#### Add New Authentication Address

addNewAuthAddr

Param:

Num |   Name |  Type   | Desc
----|-------| ---|-------
 0  |  did |  string | DID
 1  |  addr | address  | 
 2  | controller | string[] | controller of public key
 3  |  signer | bytes  | public key or address, who sign for this transaction |

event:

event AddNewAuthAddr(string did, address addr, string[] controller);

#### Add New Authentication Key By Controller

addNewAuthKeyByController

Param:

| Num |  Name | Type   | Desc       |
| ---- | ------| --- | ---------- |
| 0    | did | string | DID     |
| 1  |  pubKey | bytes  |  |
| 2  | controller | string[] | controller of public key |
| 3    | controllerSigner | string | controller who invoke this interface |
 4  |  signer | bytes  | public key or address, who sign for this transaction |

Add a new public key by did controller, the key will own authentication permission.

event:

event AddNewAuthKey(string did, bytes pubKey, string[] controller);

#### Add New Authentication Address By Controller

addNewAuthAddrByController

Param:

| Num |  Name | Type   | Desc       |
| ---- | ------| --- | ---------- |
| 0    | did | string | DID     |
| 1  |  addr | address  |  |
| 2  | controller | string[] | controller of public key |
| 3    | controllerSigner | string | controller who invoke this interface |
 4  |  signer | bytes  | public key or address, who sign for this transaction |

event:

event AddNewAuthAddr(string did, address addr, string[] controller);

#### Set Authentication Key

setAuthKey

Param:

| Num | Name | Type   | Desc       |
| ---- | -----| --- | ---------- |
| 0    | did | string | DID     |
| 1    | pubKey | bytes |  |
 2  |  signer | bytes  | public key or address, who sign for this transaction |

Make a public key existed in public key list own Authentication permission。

event:

event SetAuthKey(string did, bytes pubKey);

#### Set Authentication Address

setAuthAddr

Param:

| Num | Name | Type   | Desc       |
| ---- | -----| --- | ---------- |
| 0    | did | string | DID     |
| 1    | addr | address |  |
 2  |  signer | bytes  | public key or address, who sign for this transaction |

event:

event SetAuthAddr(string did, address addr);

#### Set Authentication Key By Controller

setAuthKeyByController

Param:

| Num | Name |  Type   | Desc       |
| ---- | ------| --- | ---------- |
| 0    | did | string | DID     |
| 1    | pubKey | bytes |  |
| 2    | controller | string | controller who invoke this interface  |
 3  |  signer | bytes  | public key or address, who sign for this transaction |

event:

event SetAuthKey(string did, bytes pubKey);

#### Set Authentication Address By Controller

setAuthAddrByController

Param:

| Num | Name |  Type   | Desc       |
| ---- | ------| --- | ---------- |
| 0    | did | string | DID     |
| 1    | addr | address |  |
| 2    | controller | string | controller who invoke this interface  |
 3  |  signer | bytes  | public key or address, who sign for this transaction |

event:

event SetAuthAddr(string did, address addr);

#### Deactivate Authentication Key

deactivateAuthKey

Param:

Num |  Name | Type   | Desc
----|--------| ---|-------
 0  |  did | string  | DID
 1  | pubKey | bytes |
 2  |  signer | bytes  | public key or address, who sign for this transaction |
 
 event:
 
 event DeactivateAuthKey(string did, bytes pubKey); 

#### Deactivate Authentication Address

deactivateAuthAddr

Param:

Num |  Name | Type   | Desc
----|--------| ---|-------
 0  |  did | string  | DID
 1  | addr | address |
 2  |  signer | bytes  | public key or address, who sign for this transaction |
 
 event:
 
 event DeactivateAuthAddr(string did, address addr); 

#### Deactivate Authentication Key By Controller

deactivateAuthKeyByController

Param:

| Num |  Name | Type   | Desc       |
| ---- | ------ | --- |-------- |
| 0    | did | string | DID     |
| 1    | pubKey | bytes |  |
| 2    | controller | string | controller who invoke this interface |
 3  |  signer | bytes  | public key or address, who sign for this transaction |

event:
 
event DeactivateAuthKey(string did, bytes pubKey);

#### Deactivate Authentication Address By Controller

deactivateAuthAddrByController

Param:

| Num |  Name | Type   | Desc       |
| ---- | ------ | --- |-------- |
| 0    | did | string | DID     |
| 1    | addr | address |  |
| 2    | controller | string | controller who invoke this interface |
 3  |  signer | bytes  | public key or address, who sign for this transaction |

event:
 
event DeactivateAuthAddr(string did, addr address);

### Service

#### Add Service

addService

Param:

Num |  Name | Type   | Desc
----|-------| ---|-------
 0  |  did | string  | DID
 1  |  serviceId | string  | service id
 2  |  serviceType | string  | service type
 3 | serviceEndpoint | string | service endpoint
 4  |  signer | bytes  | public key or address, who sign for this transaction |
 
 event:
 
 event AddService(string did, string serviceId, string serviceType, string serviceEndpoint);

#### Update Service

updateService

Param:

Num |  Name | Type   | Desc
----|--------| ---|-------
 0  |  did | string  | DID
 1  |  serviceId | string  | service id
 2  |  serviceType | string  | service type
 3 | serviceEndpoint | string | service endpoint
 4  |  signer | bytes  | public key or address, who sign for this transaction |
 
 event:
 
 event UpdateService(string did, string serviceId, string serviceType, string serviceEndpoint);

#### Remove Service

removeService

Param:

Num |  Name | Type   | Desc
----|-------| ---|-------
 0  |  did | string  | DID
 1  |  serviceId | string  | service id
 2  |  signer | bytes  | public key or address, who sign for this transaction |
 
 event:
 
 event RemoveService(string did, string serviceId);

### Context

#### Add Context

addContext

Param:

Num |  Name | Type   | Desc
----|-------| ---|-------
 0  |  did | string  | DID
 1  | contexts | string[] | 
 2  |  signer | bytes  | public key or address, who sign for this transaction |

If a context already existed, the context will be ignored.

event:

event AddContext(string did, string context);

#### Remove context

removeContext

Param:

Num |  Name | Type   | Desc
----|-------| ---|-------
 0  |  did | string  | DID
 1  | contexts | string[] |
 2  |  signer | bytes  | public key or address, who sign for this transaction |

If a context didn't exist, the context will be ignored.

event:

event RemoveContext(string did, string context);

### Verify

#### Verify Signature

verifySignature

Param:

Num |  Name | Type   | Desc
----|-------| ---|-------
 0  |  did | string  | DID
 1  |  signer | bytes  | public key or address, who sign for this transaction |

Return: True/False

#### Verify Controller Signature

verifyController

Param:

Num |  Name | Type   | Desc
----|--------|---|-------
 0  |  did | string | DID
 1  |  controller | string  | 
 2  |  signer | bytes  | public key or address, who sign for this transaction |

return: True/False

### Query Data

#### DID Document(JSON)

>note: The interface is not implemented yet.

getDocumentJson

Param:

Num | Name | Type   | Desc
----|-----|----|-------
0  | did | string | 

return: DID Document with JSON-LD format.

#### Query DID Document

getDocument

Param:

Num | Name | Type   | Desc
----|-----|----|-------
0  | did | string | 

return: DID Document。

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

#### Query Context

getContext

Param:

Num | Name | Type   | Desc
----|-----|----|-------
0  | did | string | 

return: []string

#### Query Public Key List

getAllPubKey

Param:

Num | Name | Type   | Desc
----|-----|----|-------
0  | did | string | 

return: []PublicKey

```solidity
    struct PublicKey {
        string id; // public key id
        string keyType; // public key type, in ethereum
        string[] controller; // did array, has some permission
        bytes pubKeyData; // public key or address bytes
        //        address ethAddr; // ethereum address, refer: https://www.w3.org/TR/did-spec-registries/#ethereumaddress
        bool deactivated; // is deactivated or not
        bool isPubKey; // existed in public key list or not
        //        bool isAuth; // existed in authentication list or not
        uint authIndex; // index at authentication list, 0 means no auth
    }
```

#### Query Authentication List

getAllAuthKey

Param:

Num | Name | Type   | Desc
----|-----|----|-------
0  | did | string | 

return: []PublicKey

#### Query Controller List

getAllController

Param:

Num | Name | Type   | Desc
----|-----|----|-------
0  | did | string | 

return: []string


#### Query Service List

getAllService

Param:

Num | Name | Type   | Desc
----|-----|----|-------
0  | did | string | 

return: []Service

```solidity
    struct Service {
        string serviceId;
        string serviceType;
        string serviceEndpoint;
    }
```

#### Query Created Time

getCreatedTime

Param:

Num | Name | Type   | Desc
----|-----|----|-------
0  | did | string | 

return: uint

#### Query Updated Time

getUpdatedTime

Param:

Num | Name | Type   | Desc
----|-----|----|-------
0  | did | string | 

return: uint
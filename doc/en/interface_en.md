# DID-Ethereum-solidity Interface Document

### Deactivate DID

deactivateID

Param:

Num |  Name | Type   | Desc
----|-------|---|-------
 0  |  did | string  | DID
 1  |  signerPubKey | bytes  | signer public key

event:

event Deactivate(string indexed did);

### Authorized Operation

#### Add Controller

addController

Param:

| Num | Name | Type   | Desc       |
| ---- | ----| --- | ---------- |
| 0    | did | string | DID     |
| 1    | controller | string |  |

Add a controller, calling this interface needs to be signed by the private key corresponding
to the public key with authentication authority of did.

event:

event AddController(string indexed did, string controller);

#### Remove Controller

removeController

参数:

| Num | Name | Type   | Desc       |
| ---- | ----|--- | ---------- |
| 0    | did | string | DID     |
| 1    | controller | string |  |

Remove a controller, calling this interface needs to be signed by the private key corresponding
to the public key with authentication authority of did.

event:

event RemoveController(string indexed did, string controller);

### Public Key Operation

#### Add Public Key

addKey

Param:

Num |   Name | Type   | Desc
----|--------|---|-------
 0  |  did | string  | DID
 1  |  newPubKey | bytes  | new public key
 2  |  pubKeyController | string[]  | controller of new public key（optional，default is self did）

Add a new public key that doesn't own Authentication permission, calling this interface needs to be signed by the
private key corresponding to the public key with authentication authority of did.

event:

event AddKey(string indexed did, bytes pubKey, string[] controller);

#### Deactivate Public Key

deactivateKey

Param:

Num | Name | Type   | Desc
----|-----|----|-------
 0  |  did | string  | DID
 1  |  pubKey | bytes  | 

Deactivate a public key, calling this interface needs to be signed by the
private key corresponding to the public key with authentication authority of did.

event:

event DeactivateKey(string indexed did, bytes pubKey);

### Authorized Public Key

#### Add New Authentication Key

addNewAuthKey

Param:

Num |   Name |  Type   | Desc
----|-------| ---|-------
 0  |  did |  string | DID
 1  |  pubKey | bytes  | 
 2  | controller | string[] | controller of public key

Add a new public key, the key will own authentication permission.

event:

event AddNewAuthKey(string indexed did, bytes pubKey, string[] controller);

#### Add New Authentication Key By Controller

addNewAuthKeyByController

Param:

| Num |  Name | Type   | Desc       |
| ---- | ------| --- | ---------- |
| 0    | did | string | DID     |
| 1  |  pubKey | bytes  |  |
| 2  | controller | string[] | controller of public key |
| 3    | controllerSigner | string | controller who invoke this interface |

Add a new public key by did controller, the key will own authentication permission.

event:

event AddNewAuthKey(string indexed did, bytes pubKey, string[] controller);

#### Set Authentication Key

setAuthKey

Param:

| Num | Name | Type   | Desc       |
| ---- | -----| --- | ---------- |
| 0    | did | string | DID     |
| 1    | pubKey | bytes |  |

Make a public key existed in public key list own Authentication permission。

event:

event SetAuthKey(string indexed did, bytes pubKey);

#### Set Authentication Key By Controller

setAuthKeyByController

Param:

| Num | Name |  Type   | Desc       |
| ---- | ------| --- | ---------- |
| 0    | did | string | DID     |
| 1    | pubKey | bytes |  |
| 2    | controller | string | controller who invoke this interface  |

event:

event SetAuthKey(string indexed did, bytes pubKey);

#### Deactivate Authentication Key

deactivateAuthKey

Param:

Num |  Name | Type   | Desc
----|--------| ---|-------
 0  |  did | string  | DID
 1  | pubKey | bytes |
 
 event:
 
 event DeactivateAuthKey(string indexed did, bytes pubKey); 

#### Deactivate Authentication By Controller

deactivateAuthKeyByController

Param:

| Num |  Name | Type   | Desc       |
| ---- | ------ | --- |-------- |
| 0    | did | string | DID     |
| 1    | pubKey | bytes |  |
| 2    | controller | string | controller who invoke this interface |

event:
 
event DeactivateAuthKey(string indexed did, bytes pubKey);

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
 
 event:
 
 event AddService(string indexed did, string serviceId, string serviceType, string serviceEndpoint);

#### Update Service

updateService

Param:

Num |  Name | Type   | Desc
----|--------| ---|-------
 0  |  did | string  | DID
 1  |  serviceId | string  | service id
 2  |  serviceType | string  | service type
 3 | serviceEndpoint | string | service endpoint
 
 event:
 
 event UpdateService(string indexed did, string serviceId, string serviceType, string serviceEndpoint);

#### Remove Service

removeService

Param:

Num |  Name | Type   | Desc
----|-------| ---|-------
 0  |  did | string  | DID
 1  |  serviceId | string  | service id
 
 event:
 
 event RemoveService(string indexed did, string serviceId);

### Context

#### Add Context

addContext

Param:

Num |  Name | Type   | Desc
----|-------| ---|-------
 0  |  did | string  | DID
 1  | contexts | string[] | 

If a context already existed, the context will be ignored.

event:

event AddContext(string indexed did, string context);

#### Remove context

removeContext

Param:

Num |  Name | Type   | Desc
----|-------| ---|-------
 0  |  did | string  | DID
 1  | contexts | string[] |

If a context didn't exist, the context will be ignored.

event:

event RemoveContext(string indexed did, string context);

### Verify

#### Verify Signature

verifySignature

Param:

Num |  Name | Type   | Desc
----|-------| ---|-------
 0  |  did | string  | DID

Return: True/False

#### Verify Controller Signature

verifyController

Param:

Num |  Name | Type   | Desc
----|--------|---|-------
 0  |  did | string | DID
 1  |  controller | string  | 

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
        string keyType; // public key type, in ethereum, the type is always EcdsaSecp256k1VerificationKey2019
        string[] controller; // did array, has some permission
        bytes pubKey; // public key
        bool deactivated; // is deactivated or not
        bool isPubKey; // existed in public key list or not
        bool isAuth; // existed in authentication list or not
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
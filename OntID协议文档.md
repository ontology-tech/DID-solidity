# ONT ID规范 v2.0


```
编号：OP-001
名称：ONT ID规范 v2.0
状态：草案
分类：标准
编辑：Ontology Foundation
时间：2020-02-20

```

## 摘要

ONT ID是本体基于W3C去中心化标识规范，使用区块链和密码学技术打造的去中心化身份框架，能快速标识和连接人、财、物、事，具有去中心化、自主管理、隐私保护、安全易用等特点。ONT ID 帮助用户充分保护其身份与数据的隐私和安全，赋予他们全面掌控自己的身份和数据的权利。

ONT ID规范遵循[W3C DIDs规范](https://www.w3.org/TR/did-core/)，并在此基础上进行定义扩展和功能扩展。

## 约定和术语

假定本文读者对[W3C DIDs规范](https://www.w3.org/TR/did-core/)有一定程度的了解。

本文中使用的关键字“必须 MUST”，“禁止 MUST NOT”，“要求 REQUIRED”，“应当SHALL”，“应当不 SHALL NOT”，“应该 SHOULD”，“不应该 SHOULD NOT”，“推荐 RECOMMENDED”，“可以 MAY”和“可选的 OPTIONAL”等遵循[IETF RFC 2119](https://www.ietf.org/rfc/rfc2119)规范的说明和解释。


## ONT ID格式

### ONT ID语法

ONT ID是一种遵循[IETF RFC 3986](https://www.ietf.org/rfc/rfc3986)规范的URI，**应该**由每个实体自己生成。

ONT ID的生成遵循[W3C DIDs规范](https://www.w3.org/TR/did-core/)。

ONT ID的生成方式采用ABNF方式描述如下：
```
ontid        = "did:ont:" ontid-string
ontid-string = 1* idchar
idchar       = 1-9 / A-H / J-N / P-Z / a-k / m
```
其中，"did:ont:"表示ONT ID是遵循[W3C DIDs规范](https://www.w3.org/TR/did-core/)并注册在本体区块链上的去中心化标识；idchar包含了Base58编码字符集的所有字符。

ontid-string**必须**遵循如下方法生成：

1. 生成20字节随机数。
2. 附加1字节标签位。在前一步生成的随机数前附加1字节标签位，即data = VER || h；
3. 计算4字节校验位。对data计算两次SHA256，并取结果前4字节作为校验，即checksum = SHA256(SHA256(data))[0:4]；
4. 编码。对上述结果进行Base58编码，即ontid-string = Base58(data || checksum)。

上述过程中，|| 表示连接前后两个字节串。VER的推荐取值是23。

一个ONT ID示例如下：
```
did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72
```

### ONT ID URL语法
ONT ID URL的语法遵循[W3C DIDs规范](https://www.w3.org/TR/did-core/)中关于DID URL的规定。

下面是ONT ID URL支持的语法。
```
ontid-url = "did:ont:"ontid-specific-id
		  [ ";" param ] [ "/" path ]
		  [ "?" query ] [ "#" fragment ]
```

更多信息请参考[W3C DIDs规范](https://www.w3.org/TR/did-core/)中关于[param](https://w3c.github.io/did-core/#method-specific-did-url-parameters)，[path](https://w3c.github.io/did-core/#path)，[query](https://w3c.github.io/did-core/#query)和[fragment](https://w3c.github.io/did-core/#fragment)等的规定。

## ONT ID注册和注销

ONT ID**必须**在本体区块链上注册之后才能生效，并**禁止**同一个ONT ID重复注册。

只有ONT ID的所有者或代理人才能将其注销。

某个ONT ID被注销后，其关联的一切数据包括密钥、代理人、属性及恢复人等都被删除，仅在本体区块链上保留ONT ID标识本身。

已注销的ONT ID无法继续使用，也不能再次注册启用。

## ONT ID Document

每⼀个ONT ID都会对应到⼀个ONT ID Document。

ONT ID Document是一种以[JSON-LD](https://www.w3.org/TR/json-ld/)形式对ONT ID相关信息进行序列化的方法，正如W3C DIDs规范中[DID Documents](https://www.w3.org/TR/did-core/#did-documents)的定义。

ONT ID Document的结构如下：

```json
{
  "@context": ["https://www.w3.org/ns/did/v1", "https://ontid.ont.io/did/v2"]
  "id": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72",
  "publicKey": [{...}],
  "authentication": [{...}],
  "controller": [{...}],
  "recovery": [{...}],
  "service": [{...}],
  "attribute": [{...}],
  "created": [{...}],
  "updated": [{...}],
  "proof": [{...}]
}
```

### Context

ONT ID Document**必须**包含"@context"属性。

@context其值**必须**是多个URI的有序集合，其中第一个URI的值**必须**为[https://www.w3.org/ns/did/v1](https://www.w3.org/ns/did/v1)，第二个URI的值**必须**为[https://ontid.ont.io/did/v2](https://ontid.ont.io/did/v1)。 具体参见[W3C DIDs规范](https://w3c.github.io/did-core/#production-0)中的说明。

示例如下：

```json
{
  "@context": ["https://www.w3.org/ns/did/v1","https://ontid.ont.io/did/v2"]
}
```

在实际应用过程中，W3C和本体所提供的context里面的术语可能满足不了用户的需求，需要自己定义context，此时可以使用[embedded context](https://www.w3.org/TR/json-ld/#dfn-embedded-context)进行扩展。

例如，需要为某个ONT ID新增一项附加属性，并为该属性的type值创建对应的context，并将该context发布于所有使用者均可访问的URI。在ONT ID Document中将表示为:

```json
{
  "attribute": [
	{
	  "@context": {
		"some-type": "uri-of-the-context",
	  },
	  "id": "did:ont:some-ont-id#some-attribute"
	  "type": "some-type"
	  "value": "some-value"
	},
  ]
}
```

### 标识关联

ONT ID Document**必须**包含"id"属性，以指定该Document关联的ONT ID标识。

id的值**必须**为一个有效的ONT ID。

```json
{
  "id": did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72
}
```

### 公钥关联

ONT ID Document**可以**包含"publicKey"属性，以指定该ONT ID关联的一组公钥。

公私钥对可以帮助ONT ID完成自主管理，权限分级，身份认证等功能。同一个ONT ID可以关联多个不同的公私钥对；同样，同一个公私钥对也可以管理多个不同的ONT ID。

在注册到本体区块链上时，ONT ID**应该**绑定所有者的公钥。所有者自己持有对应的私钥，私钥应当妥善保管，防止泄漏。

"publicKey"属性关联的每一个公钥对象**必须**包含的字段为 "id"，"type"，"controller"，"encoding"；**可选**字段为 "access"。

每个关联的公钥拥有自己的标识，用字段"id"进行指定。每个绑定的公钥按照关联顺序从1开始依次编号。"id"的形式为

```
did:ont:some-ont-id#keys-{index}
```

其中`{index}`即为该公钥的编号。


绑定的公钥可以被废除。已废除的公钥不可被再次启用，但仍占有原编号。

字段"type"的值为该公钥所对应的密码学算法。本体支持多种国际标准密码算法，如ECDSA签名、EdDSA签名以及SM2签名等。

字段"controller"定义了该公钥所对应私钥的持有者，其值**必须**为一个有效的ONT ID，表示该公钥被此ONT ID所控制。

"encoding"的key为该公钥所对应的编码格式，value为该公钥采用该格式编码的结果。本体所支持的编码格式有publicKeyPem, publicKeyHex以及publicKeyBase58等。

字段"access"定义了该公钥所拥有的操作权限。对权限进行限制是为了达到更精准的安全性控制。"access"的值有以下三种：
- "all"：表示拥有全部权限;
- "crud"：表示只能对该ONT ID Document本身进行增删读写的操作;
- "use"：对应"crud"以外的权限，表示拥有对该ONT ID的外部使用权。

每个公钥可以拥有一种权限。当某一个publicKey不包含"access"字段时，表示该公钥的操作权限为默认值"all"。

一个具体的Publickey属性示例如下：

```
{
  "publicKey": [
	{
	  "id": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72#keys-1",
	  "type": "EcdsaSecp256r1VerificationKey2019",
	  "controller": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72",
	  "publicKeyHex": "02a545599850544b4c0a222d594be5d59cf298f5a3fd90bff1c8caa095205901f2",
	}
  ]
}
```

### 代为管理

在ONT ID Document中，采用**可选**的"controller"属性指定代理人。

一个ONT ID可以被其他ONT ID代理控制。如果需要指定代理人，**必须**在注册ONT ID到本体区块链上时指定。

代理人ONT ID拥有被代理ONT ID的注册、修改和注销权限，但不能操作被代理ONT ID的恢复人。

特别地，当ONT ID Document中指定"controller"后，可以不指定"publicKey"。

代理人ONT ID**必须**是自主管理的。

代理人可以是一个ONT ID，也可以是若干ONT ID组成的管理组。管理组能够设置复杂的门限控制逻辑，以满足不同的安全需求。例如，设置包含n个ONT ID的管理组，并设置该管理组的控制逻辑是最少m(<=n)个ONT ID共同签名才能进行操作。该设置以如下形式表示：

```json
{
  "threshold": m,
  "members": [ID1, ID2, ... , IDn]
}
```

进一步地，可以定义递归组合的控制逻辑，即组成员可以是ONT ID，也可以是嵌套的管理组，如下所示：


```json
{
  "threshold": m1,
  "members": [
	ID1,
	{
	  "threshold": m2,
	  "members": [ID2, ...]
	},
	...
  ]
}
```

下面是一个具体示例，表示要么是did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72，要么是did:ont:AXjJnU1TJViks4KUGQruiXwkKznwVpz7Z9和did:ont:AKwf6DvKFSBxhsmhjGCvJgaxHvCEQmpZZv一起才能进行代为管理。

```json
"controller:" [
  {
	"threshold": 1,
	"members": [
	  did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72,
	  {
		"threshold": 2,
		"members": [did:ont:AXjJnU1TJViks4KUGQruiXwkKznwVpz7Z9, did:ont:AKwf6DvKFSBxhsmhjGCvJgaxHvCEQmpZZv]
	  },
	  ...
	]
  }
]，
```

在操作被代理的ONT ID时，代理人ONT ID需提供符合控制逻辑的有效数字签名。

代理人可以为被代理ONT ID关联公钥，即设定"publicKey"属性，将其转换为自主管理模式。自主管理的ONT ID无法转换成代理控制的模式。

### 恢复机制

ONT ID Document采用**可选**的"recovery"属性指定恢复人。

在ONT ID所有者意外丢失其相应密钥的情况下，恢复人可以帮助其重置密钥。恢复人能够为该ONT ID添加、废除公钥，以及更新恢复人设置。

只有自主管理的ONT ID才能设置其它ONT ID为其恢复人。

恢复人可以使用组管理的方式，规则同代理人的管理组。恢复人操作时需提供符合控制逻辑的有效数字签名。

下面是一个具体示例，表示ont:AXjJnU1TJViks4KUGQruiXwkKznwVpz7Z9或者did:ont:AKwf6DvKFSBxhsmhjGCvJgaxHvCEQmpZZv之一就进行恢复操作。

```json
"recovery": [
  {
	"threshold": 1,
	"members": [did:ont:AXjJnU1TJViks4KUGQruiXwkKznwVpz7Z9, did:ont:AKwf6DvKFSBxhsmhjGCvJgaxHvCEQmpZZv]
  }
]，
```

### 认证方式

ONT ID Document采用**可选**的"authentication"属性指定认证方法。

ONT ID允许用户添加认证属性，表示该DID的持有者授权了一组认证方法来进行身份认证。

该部分继承自[W3C DIDs规范](https://www.w3.org/TR/did-core/#services)。

一个具体示例如下：

```json
{
  ...
  "authentication": [
	"did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72#keys-1",
	{
	  "id": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72#keys-2",
	  "type": "EcdsaSecp256r1VerificationKey2019",
	  "controller": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72",
	  "publicKeyBaseHex": "03a835599850544b4c0a222d594be5d59cf298f5a3fd90bff1c8caa064523745f3"
	}
  ],
}
```

### 服务信息

ONT ID Document采用**可选**的"service"指定服务属性。

ONT ID允许实体添加服务，用于指示该ONT ID相关的某项服务的信息，包括服务类型以及访问入口等。


该部分继承自[W3C DIDs规范](https://www.w3.org/TR/did-core/#services)。

一个具体示例如下：

```json
{
  ...
  "service": [
	{
	  "id": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72#some-service",
	  "type": "SomeServiceType",
	  "serviceEndpint": "Some URL"
	}
  ]
}
```

### 附加属性

ONT ID Document包含**可选**的"attribute"来关联ONT ID相关的一组属性。

ONT ID的所有者或代理人可以为其添加、修改或删除附加属性。

每条属性**必须**包含"key", "value", "type"三个字段。其中：
- "key"作为属性的标识，
- "type"指示属性的类型，
- "value"则为属性的内容。

"attribute"中最多可以包含100条属性。

属性的字段有长度限制。其中"key"最长为80字节，"type"最长为64字节，"value"最长为512K字节。

如did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72包含一个属性：

```
key: "some-attribute"
type: "some-type"
value: "some-value"
```

那么，在其ONT ID Document中将表示为

```json
{
  "id": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72"
  "attribute": [
	{
	  "key": "some-attribute"
	  "type": "some-type"
	  "value": "some-value"
	},
  ]
}
```

附加属性的属性类型及其具体内容不在本规范的范畴内，由应用层自行定义。

一个具体属性示例如下：

```json
{
  "attribute": [
	{
	  "key": "age"
	  "type": "number"
	  "value": 18
	},
  ]
}
```


### 创建时间

ONT ID Document**应该**包含"created"属性，以指定创建时间。

该部分继承自[W3C DIDs规范](https://www.w3.org/TR/did-core/#services)。

一个具体示例如下：
```json
{
  "created": "2018-06-30T12:00:00Z"
}
```
### 更新时间

ONT ID Document**应该**包含"updated"属性，以指定更新时间。

该部分继承自[W3C DIDs规范](https://www.w3.org/TR/did-core/#services)。

一个具体示例如下：
```json
{
  "created": "2019-06-30T12:00:00Z"
}
```

### 完整性证明

ONT ID Document**可以**包含"proof"属性，以证明该ONT ID Document的完整性。

该部分继承自[W3C DIDs规范](https://www.w3.org/TR/did-core/#services)。

一个具体示例如下：
```json
{
  "proof": {
	"type": "LinkedDataSignature2015",
	"created": "2020-02-02T02:02:02Z",
	"creator": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72#keys-1",
	"signatureValue": "QNB13Y7Q9...1tzjn4w=="
  }
}
```

## 附录A
一个简单的ONT ID Document示例如下：

```json
{
  "@context": ["https://www.w3.org/ns/did/v1", "https://ontid.ont.io/did/v2"]
  "id": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72",
  "publicKey": [
	{
	  "id": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72#keys-1",
	  "type": "EcdsaSecp256r1VerificationKey2019",
	  "controller": "did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72",
	  "publicKeyHex": "02a545599850544b4c0a222d594be5d59cf298f5a3fd90bff1c8caa095205901f2"
	}
  ],
	"authentication": [
	"did:ont:AderzAExYf7yiuHicVLKmooY51i2Cdzg72#keys-1"
  ]
}
```

## 参考文献

[W3C-DID]

Decentralized Identifiers (DIDs) v1.0. W3C. Mar 2020.  Working Draft. URL: https://www.w3.org/TR/did-core/

[RFC2119]

Key words for use in RFCs to Indicate Requirement Levels. S. Bradner. IETF. March 1997. Best Current Practice. URL: https://tools.ietf.org/html/rfc2119

[RFC3986]

Uniform Resource Identifier (URI): Generic Syntax. T. Berners-Lee; R. Fielding; L. Masinter. IETF. JANUARY 2005. Standards Track. URL: https://tools.ietf.org/html/rfc3986


[BASE58]

The Base58 Encoding Scheme. Manu Sporny. IETF. December 2019. Internet-Draft. URL: https://tools.ietf.org/html/draft-msporny-base58

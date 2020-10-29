# DID-solidity

## Specification

[Spec](doc/en/DID-spec-ethereum.md)

## Design and Interface Document

We offer versions in two language:

### 中文文档

[接口文档](doc/zh/interface_zh.md)

[设计文档](doc/zh/design_zh.md)

### English Document

[interface document](doc/en/interface_en.md)

[design document](doc/en/design_en.md)

## Implementation

### Ropsten

EternalStorageProxy: 0x9fF365Eb96B2E1E6F968947F56275D2bBe50F06e

DIDContract: 0x55DE116e54220a243d2e77cEaC78B5F2B3F7f73c

### Ethereum

EternalStorageProxy: 0xBc11091d6203500C480f0305140c687aB52b224B

DIDContract: 0x5409Ff9585C9C942389f4f84EE4dc28AE2F361f1

StorageUtils: 0x49831fD1B9753b630A5b220656Dd42D6CD7aE8F1

IterableMapping: 0xeF40fd44b78775Df6FB0b19eb680475Cf2d239Ea

ZeroCopySource: 0xB51D7A841911461d4AE97A49DE78BE086A71a724

ZeroCopySink: 0x252a7aa203A6Df2F7781A124CB95C27aaE4F286C

KeyUtils: 0x22AdA8420468Ea3b3B39B87CDa5742B183c7e28b

DidUtils: 0xE21b6194903282772BCF40FEf6848F28F50B51EE

BytesUtils: 0x5E5003e1B658A9c37660F4E6a730833b8A433047

## Gas Consumed

>Note: It's just an estimate because it comes from unit test.

| name | gas |
| --- | --- |
| addKey |  555392 |
| setAuthKey |  191619 |
| deactivateAuthKey |  174081 |
| addNewAuthKey |  415953 |
| addContext |  295411 |
| removeContext |  125832 |
| addService |  238210 |
| updateService |  138008 |
| removeService |  127017 |
| deactivateKey |  174061 |
| deactivateID |  153470 |
| addController |  382943 |
| addNewAuthKeyByController |  580692 |
| setAuthKeyByController |  271635 |
| deactivateAuthKeyByController |  269118 |
|addAddr | 382321 |
|setAuthAddr | 176123 |
|deactivateAuthAddr | 165259 |
|deactivateAddr | 169394 |
|addNewAuthAddr | 388968 |
|deactivateAuthAddr | 169481 |
|addNewAuthAddrByController |  537963 |
|setAuthAddrByController |  267114 |
|deactivateAuthAddrByController |  264576 |

## TODO

1. add more unit test;
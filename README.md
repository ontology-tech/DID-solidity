# DID-Ethereum-solidity

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

## Gas Consumed

>Note: It's just an estimate because it comes from unit test.

| name | gas |
| --- | --- |
| regIDWithPublicKey |  609393 |
| addKey |  588628 |
| setAuthKey |  306040 |
| deactivateAuthKey |  286482 |
| addNewAuthKey |  524172 |
| addContext |  392427 |
| removeContext |  222770 |
| addService |  330940 |
| updateService |  234917 |
| removeService |  223965 |
| deactivateKey |  315875 |
| deactivateID |  213743 |
| addController |  417299 |
| addNewAuthKeyByController |  571270 |
| setAuthKeyByController |  277645 |
| deactivateAuthKeyByController |  256172 |
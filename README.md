# DID-solidity

## Specification

[Spec](doc/en/DID-spec-klaytn.md)

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

EternalStorageProxy: 0x1c780D5419ee4A808a324AbE23300285D420cE2F

DIDContract: 0xFDBfAF66cc8969e93E8eb157810bf7e552305d7F

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
const EternalStorageProxy = artifacts.require("EternalStorageProxy");
const DIDContractV2 = artifacts.require("DIDContractV2");
const BytesUtils = artifacts.require("BytesUtils");
const DidUtils = artifacts.require("DidUtils");
const KeyUtils = artifacts.require("KeyUtils");
const ZeroCopySink = artifacts.require("ZeroCopySink");
const ZeroCopySource = artifacts.require("ZeroCopySource");
const StorageUtils = artifacts.require("StorageUtils");

// no need to run, only for test upgrade feature
module.exports = async function (depolyer) {
    // await depolyer.link(DidUtils, DIDContractV2);
    // await depolyer.link(KeyUtils, DIDContractV2);
    // await depolyer.link(BytesUtils, DIDContractV2);
    // await depolyer.link(ZeroCopySource, DIDContractV2);
    // await depolyer.link(ZeroCopySink, DIDContractV2);
    // await depolyer.link(StorageUtils, DIDContractV2);
    //
    // await depolyer.deploy(DIDContractV2);
    // let proxy = await EternalStorageProxy.deployed();
    // let did = await DIDContractV2.deployed();
    // proxy.upgradeTo("v2.0.0", did.address);
}
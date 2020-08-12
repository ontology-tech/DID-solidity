const EternalStorageProxy = artifacts.require("EternalStorageProxy");
const DIDContract = artifacts.require("DIDContract");
const BytesUtils = artifacts.require("BytesUtils");
const DidUtils = artifacts.require("DidUtils");
const KeyUtils = artifacts.require("KeyUtils");
const ZeroCopySink = artifacts.require("ZeroCopySink");
const ZeroCopySource = artifacts.require("ZeroCopySource");
const IterableMapping = artifacts.require("IterableMapping");
const StorageUtils = artifacts.require("StorageUtils");

module.exports = async function (depolyer) {
    await depolyer.deploy(EternalStorageProxy);

    await depolyer.deploy(BytesUtils);

    await depolyer.link(BytesUtils, DidUtils);
    await depolyer.deploy(DidUtils);

    await depolyer.link(BytesUtils, KeyUtils);
    await depolyer.deploy(KeyUtils);

    await depolyer.deploy(ZeroCopySink);
    await depolyer.deploy(ZeroCopySource);
    await depolyer.deploy(IterableMapping);

    await depolyer.link(ZeroCopySource, StorageUtils);
    await depolyer.link(ZeroCopySink, StorageUtils);
    await depolyer.link(KeyUtils, StorageUtils);
    await depolyer.link(BytesUtils, StorageUtils);
    await depolyer.link(DidUtils, StorageUtils);
    await depolyer.link(IterableMapping, StorageUtils);
    await depolyer.deploy(StorageUtils);

    await depolyer.link(DidUtils, DIDContract);
    await depolyer.link(KeyUtils, DIDContract);
    await depolyer.link(BytesUtils, DIDContract);
    await depolyer.link(ZeroCopySource, DIDContract);
    await depolyer.link(ZeroCopySink, DIDContract);
    await depolyer.link(StorageUtils, DIDContract);
    await depolyer.deploy(DIDContract);

    let proxy = await EternalStorageProxy.deployed();
    let did = await DIDContract.deployed();
    await proxy.upgradeTo("v1.0.0", did.address);
}
const EternalStorageProxy = artifacts.require("EternalStorageProxy");
const DIDContract = artifacts.require("DIDContract");
const BytesUtils = artifacts.require("BytesUtils");
const DidUtils = artifacts.require("DidUtils");
const StorageUtils = artifacts.require("StorageUtils");

module.exports = async function (depolyer) {
    await depolyer.deploy(EternalStorageProxy);

    await depolyer.deploy(BytesUtils);

    await depolyer.link(BytesUtils, DidUtils);
    await depolyer.deploy(DidUtils);


    await depolyer.link(BytesUtils, StorageUtils);
    await depolyer.link(DidUtils, StorageUtils);
    await depolyer.deploy(StorageUtils);

    await depolyer.link(DidUtils, DIDContract);
    await depolyer.link(BytesUtils, DIDContract);
    await depolyer.link(StorageUtils, DIDContract);
    await depolyer.deploy(DIDContract);

    let proxy = await EternalStorageProxy.deployed();
    let did = await DIDContract.deployed();
    await proxy.upgradeTo("v1.0.0", did.address);
}
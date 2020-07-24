const EternalStorageProxy = artifacts.require("EternalStorageProxy");
const DIDContract = artifacts.require("DIDContract");
const BytesUtils = artifacts.require("BytesUtils");
const DidUtils = artifacts.require("DidUtils");
const KeyUtils = artifacts.require("KeyUtils");

module.exports = async function (depolyer) {
    await depolyer.deploy(EternalStorageProxy);
    await depolyer.deploy(BytesUtils);
    await depolyer.link(BytesUtils, DidUtils);
    await depolyer.deploy(DidUtils);
    await depolyer.deploy(KeyUtils);
    await depolyer.link(DidUtils, MixinDid);
    await depolyer.link(KeyUtils, MixinDid);
    await depolyer.link(BytesUtils, MixinDid);
    await depolyer.deploy(MixinDid);
    let proxy = await EternalStorageProxy.deployed();
    let did = await DIDContract.deployed();
    proxy.upgradeTo("v1.0.0", did.address);
}
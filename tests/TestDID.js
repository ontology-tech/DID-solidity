const eth = require('ethereumjs-util');
const EternalStorageProxy = artifacts.require("EternalStorageProxy");
const DIDContract = artifacts.require("DIDContract");
const DIDContractV2 = artifacts.require("DIDContractV2");
const BytesUtils = artifacts.require("BytesUtils");
const DidUtils = artifacts.require("DidUtils");
const KeyUtils = artifacts.require("KeyUtils");
const ZeroCopySink = artifacts.require("ZeroCopySink");
const ZeroCopySource = artifacts.require("ZeroCopySource");
const StorageUtils = artifacts.require("StorageUtils");


contract('DID', (accounts) => {
    let did = 'did:celo:' + accounts[0].slice(2).toLowerCase();
    console.log('did:', did);
    let emptySignerPubKey = new Buffer('');
    it('test for default public key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(1, allPubKey.length);
        assert.equal(accounts[0].toLowerCase(), allPubKey[0].pubKeyData.toLowerCase());
        assert.equal("EcdsaSecp256k1RecoveryMethod2020", allPubKey[0].keyType);
        assert.ok(allPubKey[0].isPubKey);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(1, allAuthPubKey.length);
        assert.equal(accounts[0].toLowerCase(), allAuthPubKey[0].pubKeyData.toLowerCase());
        assert.equal("EcdsaSecp256k1RecoveryMethod2020", allAuthPubKey[0].keyType);
    });
    let privKey = Buffer.from("34654b1fb0ee17a235950fc2b8177af4e69730b180efad7b78b772740c2c6ca0", 'hex');
    let anotherPubKey = eth.privateToPublic(privKey);
    console.log('anotherPubKey:', '0x' + anotherPubKey.toString('hex'));
    it('add another public key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let tx = await didContract.addKey(did, anotherPubKey, [did], emptySignerPubKey, {from: accounts[0]});
        console.log("addKey gas:", tx.receipt.gasUsed);
        assert.equal(1, tx.logs.length);
        let addKeyEvt = tx.logs[0];
        assert.equal("AddKey", addKeyEvt.event);
        assert.equal(did.toLowerCase(), addKeyEvt.args.did.toLowerCase());
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), addKeyEvt.args.pubKey.toLowerCase());
        assert.equal(did, addKeyEvt.args.controller[0]);
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(2, allPubKey.length);
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), allPubKey[1].pubKeyData);
        assert.ok(allPubKey[1].isPubKey);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(1, allAuthPubKey.length);
    });
    it('set auth key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let tx = await didContract.setAuthKey(did, anotherPubKey, emptySignerPubKey);
        assert.equal(1, tx.logs.length);
        console.log("setAuthKey gas:", tx.receipt.gasUsed);
        let evt = tx.logs[0];
        assert.equal("SetAuthKey", evt.event);
        assert.equal(did.toLowerCase(), evt.args.did.toLowerCase());
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), evt.args.pubKey.toLowerCase());
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(2, allPubKey.length);
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), allPubKey[1].pubKeyData);
        assert.ok(allPubKey[1].isPubKey);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(2, allAuthPubKey.length);
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), allAuthPubKey[1].pubKeyData);
        assert.equal(allAuthPubKey[1].authIndex, 2);
    });
    it('deactivate auth key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let tx = await didContract.deactivateAuthKey(did, anotherPubKey, emptySignerPubKey);
        console.log("deactivateAuthKey gas:", tx.receipt.gasUsed);
        assert.equal(1, tx.logs.length);
        let evt = tx.logs[0];
        assert.equal("DeactivateAuthKey", evt.event);
        assert.equal(did.toLowerCase(), evt.args.did.toLowerCase());
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), evt.args.pubKey.toLowerCase());
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(1, allAuthPubKey.length);
        assert.equal(allAuthPubKey[0].authIndex, 1);
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(2, allPubKey.length);
    });
    privKey = Buffer.from("436f5568bf64ccfb273da130d4a04f87f7f86d55fd5eae49da771ad2ea79cc8f", 'hex');
    let newAuthKey = eth.privateToPublic(privKey);
    console.log('newAuthKey:', '0x' + newAuthKey.toString('hex'));
    it('auth new key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let tx = await didContract.addNewAuthKey(did, newAuthKey, [did], emptySignerPubKey, {from: accounts[0]});
        console.log("addNewAuthKey gas:", tx.receipt.gasUsed);
        assert.equal(1, tx.logs.length);
        assert.equal("AddNewAuthKey", tx.logs[0].event);
        assert.equal(did.toLowerCase(), tx.logs[0].args.did.toLowerCase());
        assert.equal('0x' + newAuthKey.toString('hex').toLowerCase(), tx.logs[0].args.pubKey.toLowerCase());
        // console.log(tx.logs[0].args.controller);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(allAuthPubKey.length, 2);
        assert.equal(allAuthPubKey[0].authIndex, 1);
        assert.equal(allAuthPubKey[1].authIndex, 4);
    });
    it('add and remove context', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let ctx = ["context1", "context2"];
        let addCtxTx = await didContract.addContext(did, ctx, emptySignerPubKey);
        console.log("addContext gas:", addCtxTx.receipt.gasUsed);
        let allCtx = await didContract.getContext(did);
        // console.log(allCtx);
        assert.equal(3, allCtx.length);
        assert.equal(2, addCtxTx.logs.length);
        assert.equal("AddContext", addCtxTx.logs[0].event);
        assert.equal("AddContext", addCtxTx.logs[1].event);
        assert.equal(ctx[0], addCtxTx.logs[0].args.context);
        assert.equal(ctx[1], addCtxTx.logs[1].args.context);
        let removeCtxTx = await didContract.removeContext(did, ctx, emptySignerPubKey);
        console.log("removeContext gas:", removeCtxTx.receipt.gasUsed);
        allCtx = await didContract.getContext(did);
        // console.log(allCtx);
        assert.equal(1, allCtx.length);
        assert.equal(2, removeCtxTx.logs.length);
        assert.equal("RemoveContext", removeCtxTx.logs[0].event);
        assert.equal("RemoveContext", removeCtxTx.logs[1].event);
        assert.equal(ctx[0], removeCtxTx.logs[0].args.context);
        assert.equal(ctx[1], removeCtxTx.logs[1].args.context);
    });
    it('add, update and remove service', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let service1 = {serviceId: "111", serviceType: "222", serviceEndpoint: "333"};
        let service2 = {serviceId: "444", serviceType: "555", serviceEndpoint: "666"};
        let addServTx1 = await didContract.addService(did, service1.serviceId, service1.serviceType,
            service1.serviceEndpoint, emptySignerPubKey);
        console.log("addService gas:", addServTx1.receipt.gasUsed);
        let addServTx2 = await didContract.addService(did, service2.serviceId, service2.serviceType,
            service2.serviceEndpoint, emptySignerPubKey);
        assert.equal(1, addServTx1.logs.length);
        assert.equal(1, addServTx2.logs.length);
        assert.equal("AddService", addServTx1.logs[0].event);
        assert.equal("AddService", addServTx2.logs[0].event);
        assert.equal(service1.serviceEndpoint, addServTx1.logs[0].args.serviceEndpoint);
        assert.equal(service2.serviceId, addServTx2.logs[0].args.serviceId);
        let allServ = await didContract.getAllService(did);
        assert.equal(2, allServ.length);
        // console.log(allServ);
        let updateServTx = await didContract.updateService(did, service1.serviceId, service2.serviceType,
            service2.serviceEndpoint, emptySignerPubKey);
        console.log("updateService gas:", updateServTx.receipt.gasUsed);
        assert.equal(1, updateServTx.logs.length);
        let updateEvt = updateServTx.logs[0];
        assert.equal(service1.serviceId, updateEvt.args.serviceId);
        assert.equal(service2.serviceType, updateEvt.args.serviceType);
        assert.equal(service2.serviceEndpoint, updateEvt.args.serviceEndpoint);
        allServ = await didContract.getAllService(did);
        assert.equal(2, allServ.length);
        // console.log(allServ);
        let removeServTx1 = await didContract.removeService(did, service1.serviceId, emptySignerPubKey);
        console.log("removeService gas:", removeServTx1.receipt.gasUsed);
        assert.equal(1, removeServTx1.logs.length);
        let removeEvt = updateServTx.logs[0];
        assert.equal(service1.serviceId, removeEvt.args.serviceId);
        assert.equal(service2.serviceType, removeEvt.args.serviceType);
        assert.equal(service2.serviceEndpoint, removeEvt.args.serviceEndpoint);
        allServ = await didContract.getAllService(did);
        assert.equal(1, allServ.length);
        // console.log(allServ);
    })
    it('test verify signature', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let verified = await didContract.verifySignature(did, emptySignerPubKey);
        assert.ok(verified);
    });
    it('test get document', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let document = await didContract.getDocument(did);
        // console.log(document);
    });
    it('test upgrade', async () => {
        let byteUtils = await BytesUtils.deployed();
        let didUtils = await DidUtils.deployed();
        let keyUtils = await KeyUtils.deployed();
        let zeroCopySource = await ZeroCopySource.deployed();
        let zeroCopySink = await ZeroCopySink.deployed();
        let storageUtils = await StorageUtils.deployed();
        await DIDContractV2.link(BytesUtils, byteUtils.address);
        await DIDContractV2.link(DidUtils, didUtils.address);
        await DIDContractV2.link(KeyUtils, keyUtils.address);
        await DIDContractV2.link(ZeroCopySource, zeroCopySource.address);
        await DIDContractV2.link(ZeroCopySink, zeroCopySink.address);
        await DIDContractV2.link(StorageUtils, storageUtils.address);
        let proxy = await EternalStorageProxy.deployed();
        let did = await DIDContractV2.new();
        proxy.upgradeTo("v2.0.0", did.address);
    });
    it('test data existed after upgraded', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContractV2.at(instance.address);
        let document = await didContract.getDocument(did);
        // console.log(document);
        assert.notEqual(document, undefined);
    });
    it('test we can update document after upgraded', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContractV2.at(instance.address);
        let service1 = {serviceId: "ddd", serviceType: "sss", serviceEndpoint: "aaa"};
        let addServTx1 = await didContract.addService(did, service1.serviceId, service1.serviceType,
            service1.serviceEndpoint, emptySignerPubKey);
        assert.equal(1, addServTx1.logs.length);
        assert.equal("AddService", addServTx1.logs[0].event);
        assert.equal(service1.serviceEndpoint, addServTx1.logs[0].args.serviceEndpoint);
    });
    it('test many pub key and auth key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContractV2.at(instance.address);
        let allPubKey = await didContract.getAllPubKey(did);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        let pubKeyBeforeLen = allPubKey.length;
        let authKeyBeforeLen = allAuthPubKey.length;
        for (let i = 10; i < 30; i++) {
            let pubKey = Buffer.from("133fe269d5587d68b344f0075039059f4fbb12a1667fd7968fe" +
                "018a99de1fe358c70206f08caef079633c281cd10057ef837d07e777a8b7fc9e2e1359082b9" + i, "hex")
            let tx = await didContract.addKey(did, pubKey, [did], emptySignerPubKey, {from: accounts[0]});
            console.log("addKey gas:", tx.receipt.gasUsed);
            tx = await didContract.setAuthKey(did, pubKey, emptySignerPubKey);
            console.log("setAuthKey gas:", tx.receipt.gasUsed);
            console.log("set key:", pubKey.toString('hex'));
        }
        // deactivate some auth key
        let deactivatedAuth = [];
        for (let i = 10; i < 30; i += Math.ceil(Math.random() * 3)) {
            let pubKey = Buffer.from("133fe269d5587d68b344f0075039059f4fbb12a1667fd7968fe" +
                "018a99de1fe358c70206f08caef079633c281cd10057ef837d07e777a8b7fc9e2e1359082b9" + i, "hex")
            deactivatedAuth.push(pubKey);
            let tx = await didContract.deactivateAuthKey(did, pubKey, emptySignerPubKey);
            console.log("deactivateAuthKey gas:", tx.receipt.gasUsed);
            console.log("deactivatedAuth:", pubKey.toString('hex'));
        }
        console.log("deactivate num:", deactivatedAuth.length);
        // re-auth some auth key
        for (let i = 0; i < deactivatedAuth.length / 2; i++) {
            let pubKey = deactivatedAuth[i];
            let tx = await didContract.setAuthKey(did, pubKey, emptySignerPubKey);
            console.log("setAuthKey gas:", tx.receipt.gasUsed);
            console.log("re-auth:", pubKey.toString('hex'));
        }
        allPubKey = await didContract.getAllPubKey(did);
        allAuthPubKey = await didContract.getAllAuthKey(did);
        let pubKeyAfterLen = allPubKey.length;
        let authKeyAfterLen = allAuthPubKey.length;
        assert.equal(20, pubKeyAfterLen - pubKeyBeforeLen);
        // assert.equal(20, authKeyAfterLen - authKeyBeforeLen + deactivatedAuth.length / 2);
        for (let i = 0; i < authKeyAfterLen - 1; i++) {
            console.log(allAuthPubKey[i + 1].authIndex, ">", allAuthPubKey[i].authIndex);
            // assert.ok(allAuthPubKey[i + 1].authIndex > allAuthPubKey[i].authIndex);
        }
    });
    it('test deactivate key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContractV2.at(instance.address);
        let allPubKey = await didContract.getAllPubKey(did);
        for (let i = 0; i < allPubKey.length; i++) {
            let pubKey = allPubKey[i];
            if (pubKey.pubKeyData.length !== 130) {
                continue;
            }
            let tx = await didContract.deactivateKey(did, pubKey.pubKeyData, emptySignerPubKey, {from: accounts[0]});
            assert.equal(1, tx.logs.length);
            console.log("deactivateKey gas:", tx.receipt.gasUsed);
        }
        allPubKey = await didContract.getAllPubKey(did);
        assert.equal(1, allPubKey.length);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(allAuthPubKey.length, 2);
    });
    it('test addAddr and setAuthAddr', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContractV2.at(instance.address);
        let tx = await didContract.addAddr(did, accounts[1], [did], emptySignerPubKey, {from: accounts[0]});
        console.log('addAddr gas:', tx.receipt.gasUsed);
        assert.equal(tx.logs.length, 1);
        assert.equal(tx.logs[0].event, "AddAddr");
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(allPubKey.length, 2);
        assert.equal(allPubKey[1].pubKeyData.toLowerCase(), accounts[1].toLowerCase());
        assert.equal(allPubKey[1].keyType, "EcdsaSecp256k1RecoveryMethod2020");

        tx = await didContract.setAuthAddr(did, accounts[1], emptySignerPubKey, {from: accounts[0]});
        console.log('setAuthAddr gas:', tx.receipt.gasUsed);
        assert.equal(tx.logs.length, 1);
        assert.equal(tx.logs[0].event, "SetAuthAddr");
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(allAuthPubKey.length, 3);
    });
    it('test deactivate auth addr and deactivate addr', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContractV2.at(instance.address);
        let tx = await didContract.deactivateAuthAddr(did, accounts[1], emptySignerPubKey, {from: accounts[0]});
        console.log('deactivateAuthAddr gas:', tx.receipt.gasUsed);
        assert.equal(tx.logs.length, 1);
        assert.equal(tx.logs[0].event, "DeactivateAuthAddr");
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(allAuthPubKey.length, 2);

        tx = await didContract.deactivateAddr(did, accounts[1], emptySignerPubKey, {from: accounts[0]});
        console.log('deactivateAddr gas:', tx.receipt.gasUsed);
        assert.equal(tx.logs.length, 1);
        assert.equal(tx.logs[0].event, "DeactivateAddr");
        allPubKey = await didContract.getAllPubKey(did);
        assert.equal(allPubKey.length, 1);
    });
    it('test new auth addr', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContractV2.at(instance.address);
        let tx = await didContract.addNewAuthAddr(did, accounts[5], [did], emptySignerPubKey, {from: accounts[0]});
        console.log('addNewAuthAddr gas:', tx.receipt.gasUsed);
        assert.equal(tx.logs.length, 1);
        assert.equal(tx.logs[0].event, "AddNewAuthAddr");
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(allAuthPubKey.length, 3);

        tx = await didContract.deactivateAuthAddr(did, accounts[5], emptySignerPubKey, {from: accounts[0]});
        console.log('deactivateAuthAddr gas:', tx.receipt.gasUsed);
        assert.equal(tx.logs.length, 1);
        assert.equal(tx.logs[0].event, "DeactivateAuthAddr");
        allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(allAuthPubKey.length, 2);
    });
    it('deactivate did', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContractV2.at(instance.address);
        let tx = await didContract.deactivateID(did, newAuthKey, {from: accounts[2]});
        assert.equal(1, tx.logs.length);
        assert.equal("Deactivate", tx.logs[0].event);
        assert.equal(did.toLowerCase(), tx.logs[0].args.did.toLowerCase());
        console.log("deactivateID gas:", tx.receipt.gasUsed);
        // re-register will failed
        // tx = await didContract.regWithPubKey(did, pubKey);
    });
});
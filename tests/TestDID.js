const eth = require('ethereumjs-util');
const EternalStorageProxy = artifacts.require("EternalStorageProxy");
const DIDContract = artifacts.require("DIDContract");
const keccak256 = require('js-sha3').keccak256;

contract('DID', (accounts) => {
    // generate different did at every test
    let did, pubKey;
    it('register did with public key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let hash = keccak256(Date.now().toString());
        let addr = "0x" + hash.substring(hash.length - 40, hash.length);
        did = 'did:celo:' + addr;
        console.log(did);
        let privKey = Buffer.from("515b4666f4329520309a8fc59de7f5af44829c9e5f5d51c281b294999fb3cd60", 'hex');
        pubKey = eth.privateToPublic(privKey);
        console.log(pubKey.toString('hex'));
        let registerTx = await didContract.regIDWithPublicKey(did, pubKey, {from: accounts[0]});
        // 2 event are add context, 1 event is register
        assert.equal(3, registerTx.logs.length);
        let registerEvent = registerTx.logs[2];
        assert.equal("Register", registerEvent.event);
        assert.equal(did, registerEvent.args.did);
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(1, allPubKey.length);
        assert.equal('0x' + pubKey.toString('hex').toLowerCase(), allPubKey[0].pubKey);
        assert.ok(allPubKey[0].isPubKey);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(1, allAuthPubKey.length);
        assert.equal('0x' + pubKey.toString('hex').toLowerCase(), allAuthPubKey[0].pubKey);
        assert.ok(allAuthPubKey[0].isAuth);
    });
    let anotherPubKey;
    it('add another public key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let privKey = Buffer.from("34654b1fb0ee17a235950fc2b8177af4e69730b180efad7b78b772740c2c6ca0", 'hex');
        anotherPubKey = eth.privateToPublic(privKey);
        console.log(anotherPubKey.toString('hex'));
        let tx = await didContract.addKey(did, anotherPubKey, [did], {from: accounts[0]});
        // 2 event are add context, 1 event is register
        assert.equal(1, tx.logs.length);
        let addKeyEvt = tx.logs[0];
        assert.equal("AddKey", addKeyEvt.event);
        assert.equal(did, addKeyEvt.args.did);
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), addKeyEvt.args.pubKey.toLowerCase());
        assert.equal(did, addKeyEvt.args.controller[0]);
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(2, allPubKey.length);
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), allPubKey[1].pubKey);
        assert.ok(allPubKey[1].isPubKey);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(1, allAuthPubKey.length);
    });
    it('set auth key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let tx = await didContract.setAuthKey(did, anotherPubKey);
        assert.equal(1, tx.logs.length);
        let evt = tx.logs[0];
        assert.equal("SetAuthKey", evt.event);
        assert.equal(did, evt.args.did);
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), evt.args.pubKey.toLowerCase());
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(2, allPubKey.length);
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), allPubKey[1].pubKey);
        assert.ok(allPubKey[1].isPubKey);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(2, allAuthPubKey.length);
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), allAuthPubKey[1].pubKey);
        assert.ok(allAuthPubKey[1].isAuth);
    });
    it('deactivate auth key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let tx = await didContract.deactivateAuthKey(did, anotherPubKey);
        assert.equal(1, tx.logs.length);
        let evt = tx.logs[0];
        assert.equal("DeactivateAuthKey", evt.event);
        assert.equal(did, evt.args.did);
        assert.equal('0x' + anotherPubKey.toString('hex').toLowerCase(), evt.args.pubKey.toLowerCase());
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(1, allAuthPubKey.length);
    });
    it('auth new key', async () => {
        let privKey = Buffer.from("436f5568bf64ccfb273da130d4a04f87f7f86d55fd5eae49da771ad2ea79cc8f", 'hex');
        let newAuthKey = eth.privateToPublic(privKey);
        console.log(anotherPubKey.toString('hex'));
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let tx = await didContract.addNewAuthKey(did, newAuthKey, [did], {from: accounts[0]});
        assert.equal(1, tx.logs.length);
        assert.equal("AddNewAuthKey", tx.logs[0].event);
        assert.equal(did, tx.logs[0].args.did);
        assert.equal('0x' + newAuthKey.toString('hex').toLowerCase(), tx.logs[0].args.pubKey.toLowerCase());
        console.log(tx.logs[0].args.controller);
    });
    it('add and remove context', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let ctx = ["context1", "context2"];
        let addCtxTx = await didContract.addContext(did, ctx);
        let allCtx = await didContract.getContext(did);
        console.log(allCtx);
        assert.equal(4, allCtx.length);
        assert.equal(2, addCtxTx.logs.length);
        assert.equal("AddContext", addCtxTx.logs[0].event);
        assert.equal("AddContext", addCtxTx.logs[1].event);
        assert.equal(ctx[0], addCtxTx.logs[0].args.context);
        assert.equal(ctx[1], addCtxTx.logs[1].args.context);
        let removeCtxTx = await didContract.removeContext(did, ctx);
        allCtx = await didContract.getContext(did);
        console.log(allCtx);
        assert.equal(2, allCtx.length);
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
            service1.serviceEndpoint);
        let addServTx2 = await didContract.addService(did, service2.serviceId, service2.serviceType,
            service2.serviceEndpoint);
        assert.equal(1, addServTx1.logs.length);
        assert.equal(1, addServTx2.logs.length);
        assert.equal("AddService", addServTx1.logs[0].event);
        assert.equal("AddService", addServTx2.logs[0].event);
        assert.equal(service1.serviceEndpoint, addServTx1.logs[0].args.serviceEndpoint);
        assert.equal(service2.serviceId, addServTx2.logs[0].args.serviceId);
        let allServ = await didContract.getAllService(did);
        assert.equal(2, allServ.length);
        console.log(allServ);
        let updateServTx = await didContract.updateService(did, service1.serviceId, service2.serviceType,
            service2.serviceEndpoint);
        assert.equal(1, updateServTx.logs.length);
        let updateEvt = updateServTx.logs[0];
        assert.equal(service1.serviceId, updateEvt.args.serviceId);
        assert.equal(service2.serviceType, updateEvt.args.serviceType);
        assert.equal(service2.serviceEndpoint, updateEvt.args.serviceEndpoint);
        allServ = await didContract.getAllService(did);
        assert.equal(2, allServ.length);
        console.log(allServ);
        let removeServTx1 = await didContract.removeService(did, service1.serviceId);
        assert.equal(1, removeServTx1.logs.length);
        let removeEvt = updateServTx.logs[0];
        assert.equal(service1.serviceId, removeEvt.args.serviceId);
        assert.equal(service2.serviceType, removeEvt.args.serviceType);
        assert.equal(service2.serviceEndpoint, removeEvt.args.serviceEndpoint);
        allServ = await didContract.getAllService(did);
        assert.equal(1, allServ.length);
        console.log(allServ);
    })
    it('test verify signature', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let verified = await didContract.verifySignature(did);
        assert.ok(verified);
    });
    it('test deactivate key', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let allPubKey = await didContract.getAllPubKey(did);
        // deactivate key that has no authentication firstlly
        for (let i = 0; i < allPubKey.length; i++) {
            let pubKey = allPubKey[i];
            if (pubKey.isAuth) {
                continue;
            }
            let tx = await didContract.deactivateKey(did, pubKey.pubKey);
            assert.equal(1, tx.logs.length);
            console.log(tx.logs[0].did, "deactivate", tx.logs[0].pubKey);
        }
        for (let i = 0; i < allPubKey.length; i++) {
            let pubKey = allPubKey[i];
            let tx = await didContract.deactivateKey(did, pubKey.pubKey);
            assert.equal(1, tx.logs.length);
            console.log(tx.logs[0].did, "deactivate", tx.logs[0].pubKey);
        }
    });
    it('test get document', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let document = await didContract.getDocument(did);
        console.log(document);
    });
    it('deactivate did', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let tx = await didContract.deactivateID(did);
        assert.equal(1, tx.logs.length);
        assert.equal("Deactivate", tx.logs[0].event);
        assert.equal(did, tx.logs[0].args.did);
        // re-register will failed
        // tx = await didContract.regWithPubKey(did, pubKey);
    });
});
const eth = require('ethereumjs-util');
const EternalStorageProxy = artifacts.require("EternalStorageProxy");
const DIDContract = artifacts.require("DIDContract");
const keccak256 = require('js-sha3').keccak256;

contract('DID', (accounts) => {
    // generate different did at every test
    let did, pubKey;
    let controller, controllerPubKey;
    it('add controller', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        // register one did
        let hash = keccak256(Date.now().toString());
        let addr = hash.substring(hash.length - 40, hash.length);
        did = 'did:etho:' + addr;
        console.log(did);
        let privKey = Buffer.from("515b4666f4329520309a8fc59de7f5af44829c9e5f5d51c281b294999fb3cd60", 'hex');
        pubKey = eth.privateToPublic(privKey);
        console.log(pubKey.toString('hex'));
        let registerTx = await didContract.regIDWithPublicKey(did, pubKey, {from: accounts[0]});
        // 1 event are add context, 1 event is register
        assert.equal(2, registerTx.logs.length);
        let registerEvent = registerTx.logs[1];
        assert.equal("Register", registerEvent.event);
        assert.equal(did, registerEvent.args.did);
        // use accounts[1] public key to register another did as controller
        hash = keccak256(Date.now().toString() + accounts[1]);
        addr = hash.substring(hash.length - 40, hash.length);
        controller = 'did:etho:' + addr;
        console.log(controller);
        privKey = Buffer.from("34654b1fb0ee17a235950fc2b8177af4e69730b180efad7b78b772740c2c6ca0", 'hex');
        controllerPubKey = eth.privateToPublic(privKey);
        console.log(controllerPubKey.toString('hex'));
        registerTx = await didContract.regIDWithPublicKey(controller, controllerPubKey, {from: accounts[1]});
        // 1 event are add context, 1 event is register
        assert.equal(2, registerTx.logs.length);
        registerEvent = registerTx.logs[1];
        assert.equal("Register", registerEvent.event);
        assert.equal(controller, registerEvent.args.did);
        // add controller
        let addControllerTx = await didContract.addController(did, controller);
        assert.equal(1, addControllerTx.logs.length);
        assert.equal("AddController", addControllerTx.logs[0].event);
        assert.equal(did, addControllerTx.logs[0].args.did);
        assert.equal(controller, addControllerTx.logs[0].args.controller);
    });
    it('add new auth key by controller', async () => {
        let privKey = Buffer.from("436f5568bf64ccfb273da130d4a04f87f7f86d55fd5eae49da771ad2ea79cc8f", 'hex');
        let newAuthKey = eth.privateToPublic(privKey);
        console.log(newAuthKey.toString('hex'));
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let newAuthKeyController = [did, controller];
        // use controller to sign tx
        let tx = await didContract.addNewAuthKeyByController(did, newAuthKey, newAuthKeyController,
            controller, {from: accounts[1]});
        assert.equal(1, tx.logs.length);
        let evt = tx.logs[0];
        assert.equal('AddNewAuthKey', evt.event);
        assert.equal(did, evt.args.did);
        assert.equal('0x' + newAuthKey.toString('hex').toLowerCase(), evt.args.pubKey);
        console.log(evt.args.controller);
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(1, allPubKey.length);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(2, allAuthPubKey.length);
        assert.equal('0x' + newAuthKey.toString('hex').toLowerCase(), allAuthPubKey[1].pubKey);
        assert.ok(allAuthPubKey[1].isAuth);
    });
    it('set auth key by controller', async () => {
        // add another key, this key has no authentication
        let privKey = Buffer.from("30b9a20f95cd7a3acd48fcbd15a3628e295d2fd6233027e3162e57834cd44302", 'hex');
        let anotherKey = eth.privateToPublic(privKey);
        console.log(anotherKey.toString('hex'));
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let addKeyTx = await didContract.addKey(did, anotherKey, [did], {from: accounts[0]});
        console.log(addKeyTx.logs);
        // set auth by controller
        let setAuthKeyTx = await didContract.setAuthKeyByController(did, anotherKey, controller,
            {from: accounts[1]});
        assert.equal(1, setAuthKeyTx.logs.length);
        let evt = setAuthKeyTx.logs[0];
        assert.equal("SetAuthKey", evt.event);
        assert.equal(did, evt.args.did);
        assert.equal('0x' + anotherKey.toString('hex').toLowerCase(), evt.args.pubKey.toLowerCase());
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(2, allPubKey.length);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(3, allAuthPubKey.length);
        assert.ok(allAuthPubKey[2].isAuth);
    });
    it('deactivate auth key by controller', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let tx = await didContract.deactivateAuthKeyByController(did, pubKey, controller,
            {from: accounts[1]});
        assert.equal(1, tx.logs.length);
        let evt = tx.logs[0];
        assert.equal("DeactivateAuthKey", evt.event);
        console.log(evt);
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(2, allPubKey.length);
        console.log(allPubKey);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(2, allAuthPubKey.length);
        console.log(allAuthPubKey);
    });
    it('verify controller', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let verified = await didContract.verifyController(did, controller, {from: accounts[1]})
        assert.ok(verified);
    });
});
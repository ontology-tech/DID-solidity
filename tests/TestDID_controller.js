const eth = require('ethereumjs-util');
const EternalStorageProxy = artifacts.require("EternalStorageProxy");
const DIDContract = artifacts.require("DIDContract");
const keccak256 = require('js-sha3').keccak256;

contract('DID', (accounts) => {
    // generate different did at every test
    let did = 'did:etho:' + accounts[0].slice(2);
    console.log('did:', did);
    let controller = 'did:etho:' + accounts[1].slice(2);
    console.log('controller:', controller);
    it('add controller', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        // add controller
        let addControllerTx = await didContract.addController(did, controller);
        console.log("addController gas: ", addControllerTx.receipt.gasUsed);
        assert.equal(1, addControllerTx.logs.length);
        assert.equal("AddController", addControllerTx.logs[0].event);
        assert.equal(did, addControllerTx.logs[0].args.did);
        assert.equal(controller, addControllerTx.logs[0].args.controller);
    });
    let privKey = Buffer.from("436f5568bf64ccfb273da130d4a04f87f7f86d55fd5eae49da771ad2ea79cc8f", 'hex');
    let newAuthKey = eth.privateToPublic(privKey);
    console.log('newAuthKey:', newAuthKey.toString('hex'));
    it('add new auth key by controller', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let newAuthKeyController = [did, controller];
        // use controller to sign tx
        let tx = await didContract.addNewAuthKeyByController(did, newAuthKey, newAuthKeyController,
            controller, {from: accounts[1]});
        console.log("addNewAuthKeyByController gas: ", tx.receipt.gasUsed);
        assert.equal(1, tx.logs.length);
        let evt = tx.logs[0];
        assert.equal('AddNewAuthKey', evt.event);
        assert.equal(did, evt.args.did);
        assert.equal('0x' + newAuthKey.toString('hex').toLowerCase(), evt.args.pubKey);
        // console.log(evt.args.controller);
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(1, allPubKey.length);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(2, allAuthPubKey.length);
        assert.equal('0x' + newAuthKey.toString('hex').toLowerCase(), allAuthPubKey[1].pubKey);
        assert.ok(allAuthPubKey[1].isAuth);
    });
    // add another key, this key has no authentication
    privKey = Buffer.from("30b9a20f95cd7a3acd48fcbd15a3628e295d2fd6233027e3162e57834cd44302", 'hex');
    let anotherKey = eth.privateToPublic(privKey);
    console.log('anotherKey:', anotherKey.toString('hex'));
    it('set auth key by controller', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        await didContract.addKey(did, anotherKey, [did], {from: accounts[0]});
        // set auth by controller
        let setAuthKeyTx = await didContract.setAuthKeyByController(did, anotherKey, controller,
            {from: accounts[1]});
        console.log("setAuthKeyByController gas: ", setAuthKeyTx.receipt.gasUsed);
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
        let tx = await didContract.deactivateAuthKeyByController(did, anotherKey, controller,
            {from: accounts[1]});
        console.log("deactivateAuthKeyByController gas: ", tx.receipt.gasUsed);
        assert.equal(1, tx.logs.length);
        let evt = tx.logs[0];
        assert.equal("DeactivateAuthKey", evt.event);
        // console.log(evt);
        let allPubKey = await didContract.getAllPubKey(did);
        assert.equal(2, allPubKey.length);
        // console.log(allPubKey);
        let allAuthPubKey = await didContract.getAllAuthKey(did);
        assert.equal(2, allAuthPubKey.length);
        // console.log(allAuthPubKey);
    });
    it('verify controller', async () => {
        let instance = await EternalStorageProxy.deployed();
        let didContract = await DIDContract.at(instance.address);
        let verified = await didContract.verifyController(did, controller, {from: accounts[1]})
        assert.ok(verified);
    });
});
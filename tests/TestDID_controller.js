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
        // register another did as controller
        hash = keccak256((Date.now() + 1).toString());
        addr = "0x" + hash.substring(hash.length - 40, hash.length);
        controller = 'did:celo:' + addr;
        console.log(did);
        privKey = Buffer.from("34654b1fb0ee17a235950fc2b8177af4e69730b180efad7b78b772740c2c6ca0", 'hex');
        controllerPubKey = eth.privateToPublic(privKey);
        console.log(controllerPubKey.toString('hex'));
        registerTx = await didContract.regIDWithPublicKey(controller, controllerPubKey, {from: accounts[1]});
        // 2 event are add context, 1 event is register
        assert.equal(3, registerTx.logs.length);
        registerEvent = registerTx.logs[2];
        assert.equal("Register", registerEvent.event);
        assert.equal(controller, registerEvent.args.did);
        // add controller
        let addControllerTx = await didContract.addController(did, controller);
        assert.equal(1, addControllerTx.logs.length);
        assert.equal("AddController", addControllerTx.logs[0].event);
        assert.equal(did, addControllerTx.logs[0].args.did);
        assert.equal(controller, addControllerTx.logs[0].args.controller);
    });
});
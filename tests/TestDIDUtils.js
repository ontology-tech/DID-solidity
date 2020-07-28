const util = require('ethereumjs-util');
const DidUtils = artifacts.require("DidUtils");


contract('DidUtils', (accounts) => {
    it("verify did format", async () => {
        let didUtils = await DidUtils.deployed();
        let r1 = await didUtils.verifyDIDFormat("did:eth:0x4c78c9baff8cf573f1e6dfc11bf3a027934aa818");
        let r2 = await didUtils.verifyDIDFormat("did:eth:4c78c9baff8cf573f1e6dfc11bf3a027934aa818");
        let r3 = await didUtils.verifyDIDFormat(":eth:0x4c78c9baff8cf573f1e6dfc11bf3a027934aa818");
        let r4 = await didUtils.verifyDIDFormat("did::0x4c78c9baff8cf573f1e6dfc11bf3a027934aa818");
        let r5 = await didUtils.verifyDIDFormat("did:eth:0x4c78caff8cf573f1e6dfc11bf3a027934aa818");
        assert.equal(r1, true);
        assert.equal(r2, true);
        assert.equal(r3, false);
        assert.equal(r4, false);
        assert.equal(r5, false);
    })
    it('pub key to address', async () => {
        let didUtils = await DidUtils.deployed();
        let buffer = Buffer.from("436f5568bf64ccfb273da130d4a04f87f7f86d55fd5eae49da771ad2ea79cc8f", 'hex');
        let pubKey = util.privateToPublic(buffer);
        console.log("pub key", pubKey.toString('hex'))
        let addr = await didUtils.pubKeyToAddr(pubKey);
        console.log("addr", addr);
        assert.equal(addr.toLowerCase(), '0x4c78c9baff8cF573f1e6dFC11bf3A027934AA818'.toLowerCase());
    })
});
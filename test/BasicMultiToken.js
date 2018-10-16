const EVMRevert = require('./helpers/EVMRevert');
const EVMThrow = require('./helpers/EVMThrow');

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

const Token = artifacts.require('Token.sol');
const BadToken = artifacts.require('BadToken.sol');
const BrokenTransferToken = artifacts.require('BrokenTransferToken.sol');
const BrokenTransferFromToken = artifacts.require('BrokenTransferFromToken.sol');
const BasicMultiToken = artifacts.require('BasicMultiToken.sol');

contract('BasicMultiToken', function ([_, wallet1, wallet2, wallet3, wallet4, wallet5]) {
    let abc;
    let xyz;
    let lmn;
    let multi;

    beforeEach(async function () {
        abc = await Token.new('ABC');
        await abc.mint(_, 1000e6);
        await abc.mint(wallet1, 50e6);
        await abc.mint(wallet2, 50e6);

        xyz = await BadToken.new('BadToken', 'XYZ', 18);
        await xyz.mint(_, 500e6);
        await xyz.mint(wallet1, 50e6);
        await xyz.mint(wallet2, 50e6);

        lmn = await Token.new('LMN');
        await lmn.mint(_, 100e6);
    });

    it('should fail to create multitoken with wrong arguments', async function () {
        const mtkn = await BasicMultiToken.new();
        await mtkn.init([abc.address], 'Multi', '1ABC', 18).should.be.rejectedWith(EVMRevert);
        await mtkn.init([xyz.address], 'Multi', '1XYZ', 18).should.be.rejectedWith(EVMRevert);
        await mtkn.init([abc.address, xyz.address], '', '1ABC', 18).should.be.rejectedWith(EVMRevert);
        await mtkn.init([abc.address, xyz.address], 'Multi', '', 18).should.be.rejectedWith(EVMRevert);
        await mtkn.init([abc.address, xyz.address], 'Multi', '1ABC', 0).should.be.rejectedWith(EVMRevert);
    });

    describe('bundle', async function () {
        beforeEach(async function () {
            multi = await BasicMultiToken.new();
            await multi.init([abc.address, xyz.address], 'Multi', '1ABC_1XYZ', 18);
        });

        it('should not bundle first tokens with bundle method', async function () {
            await multi.bundle(_, 1).should.be.rejectedWith(EVMRevert);
        });

        it('should bundle second tokens with bundle method', async function () {
            await abc.approve(multi.address, 1000e6);
            await xyz.approve(multi.address, 500e6);
            await multi.bundleFirstTokens(_, 1000, [1000e6, 500e6]);

            await abc.approve(multi.address, 10e6, { from: wallet1 });
            await xyz.approve(multi.address, 5e6, { from: wallet1 });
            await multi.bundle(wallet1, 10, { from: wallet1 });
        });

        it('should bundle first tokens with bundleFirstTokens method', async function () {
            await abc.approve(multi.address, 1000e6);
            await xyz.approve(multi.address, 500e6);
            await multi.bundleFirstTokens(_, 1000, [1000e6, 500e6]);
        });

        it('should not bundle second tokens with bundleFirstTokens method', async function () {
            await abc.approve(multi.address, 1002e6);
            await xyz.approve(multi.address, 501e6);
            await multi.bundleFirstTokens(_, 1000, [1000e6, 500e6]);
            await multi.bundleFirstTokens(_, 1, [2e6, 1e6]).should.be.rejectedWith(EVMRevert);
        });

        it('should not bundle invalid number of volumes', async function () {
            await abc.approve(multi.address, 1002e6);
            await xyz.approve(multi.address, 501e6);
            await multi.bundleFirstTokens(_, 1000, [1000e6, 500e6, 100e6]).should.be.rejectedWith(EVMRevert);
            await multi.bundleFirstTokens(_, 1, [2e6]).should.be.rejectedWith(EVMRevert);
        });

        it('should handle wrong transferFrom of tokens', async function () {
            const _abc = await BrokenTransferFromToken.new('ABC');
            await _abc.mint(_, 1000e6);
            const _xyz = await BrokenTransferFromToken.new('XYZ');
            await _xyz.mint(_, 500e6);

            const brokenMulti = await BasicMultiToken.new();
            await brokenMulti.init([_abc.address, _xyz.address], 'Multi', '1ABC_1XYZ', 18);
            await _abc.approve(brokenMulti.address, 1000e6);
            await _xyz.approve(brokenMulti.address, 500e6);
            await brokenMulti.bundleFirstTokens(_, 1000, [1000e6, 500e6]).should.be.rejectedWith(EVMRevert);
        });
    });

    describe('unbundle', async function () {
        beforeEach(async function () {
            multi = await BasicMultiToken.new();
            await multi.init([abc.address, xyz.address], 'Multi', '1ABC_1XYZ', 18);
            await abc.approve(multi.address, 1000e6);
            await xyz.approve(multi.address, 500e6);
            await multi.bundleFirstTokens(_, 1000, [1000e6, 500e6]);
        });

        it('should not unbundle when no tokens', async function () {
            await multi.unbundle(wallet1, 1, { from: wallet1 }).should.be.rejectedWith(EVMThrow);
        });

        it('should not unbundle too many tokens', async function () {
            await multi.unbundle(_, 1001).should.be.rejectedWith(EVMThrow);
        });

        it('should unbundle owned tokens', async function () {
            await multi.unbundle(_, 200);
            await multi.unbundle(_, 801).should.be.rejectedWith(EVMThrow);
            await multi.unbundle(_, 300);
            await multi.unbundle(_, 501).should.be.rejectedWith(EVMThrow);
            await multi.unbundle(_, 500);
            await multi.unbundle(_, 1).should.be.rejectedWith(EVMThrow);

            (await abc.balanceOf.call(multi.address)).should.be.bignumber.equal(0);
            (await xyz.balanceOf.call(multi.address)).should.be.bignumber.equal(0);
        });

        it('should not be able to unbundle none tokens', async function () {
            await multi.unbundleSome(_, 100, []).should.be.rejectedWith(EVMRevert);
        });

        it('should be able to unbundleSome in case of first tokens paused', async function () {
            await abc.pause();
            await multi.unbundle(_, 500).should.be.rejectedWith(EVMRevert);

            const xyzBalance = await xyz.balanceOf.call(multi.address);
            await multi.unbundleSome(_, 500, [xyz.address]);
            (await multi.balanceOf.call(_)).should.be.bignumber.equal(500);
            (await xyz.balanceOf.call(_)).should.be.bignumber.equal(xyzBalance / 2);
        });

        it('should be able to unbundleSome in case of last tokens paused', async function () {
            await xyz.pause();
            await multi.unbundle(_, 500).should.be.rejectedWith(EVMRevert);

            const abcBalance = await abc.balanceOf.call(multi.address);
            await multi.unbundleSome(_, 500, [abc.address]);
            (await multi.balanceOf.call(_)).should.be.bignumber.equal(500);
            (await abc.balanceOf.call(_)).should.be.bignumber.equal(abcBalance / 2);
        });

        it('should be able to receive airdrop while unbundle', async function () {
            await lmn.transfer(multi.address, 100e6);

            const lmnBalance = await lmn.balanceOf.call(multi.address);
            await multi.unbundleSome(_, 500, [abc.address, xyz.address, lmn.address]);
            (await multi.balanceOf.call(_)).should.be.bignumber.equal(500);
            (await lmn.balanceOf.call(_)).should.be.bignumber.equal(lmnBalance / 2);
        });

        it('should handle wrong transfer of first token', async function () {
            const _abc = await BrokenTransferToken.new('ABC');
            await _abc.mint(_, 1000e6);
            const _xyz = await Token.new('XYZ');
            await _xyz.mint(_, 500e6);

            const brokenMulti = await BasicMultiToken.new();
            await brokenMulti.init([_abc.address, _xyz.address], 'Multi', '1ABC_1XYZ', 18);
            await _abc.approve(brokenMulti.address, 1000e6);
            await _xyz.approve(brokenMulti.address, 500e6);
            await brokenMulti.bundleFirstTokens(_, 1000, [1000e6, 500e6]);

            await brokenMulti.unbundle(_, 100).should.be.rejectedWith(EVMRevert);
            await brokenMulti.unbundleSome(_, 100, [_abc.address]).should.be.rejectedWith(EVMRevert);
            await brokenMulti.unbundleSome(_, 100, [_xyz.address]).should.be.fulfilled;
        });

        it('should handle wrong transfer of last token', async function () {
            const _abc = await Token.new('ABC');
            await _abc.mint(_, 1000e6);
            const _xyz = await BrokenTransferToken.new('XYZ');
            await _xyz.mint(_, 500e6);

            const brokenMulti = await BasicMultiToken.new();
            await brokenMulti.init([_abc.address, _xyz.address], 'Multi', '1ABC_1XYZ', 18);
            await _abc.approve(brokenMulti.address, 1000e6);
            await _xyz.approve(brokenMulti.address, 500e6);
            await brokenMulti.bundleFirstTokens(_, 1000, [1000e6, 500e6]);

            await brokenMulti.unbundle(_, 100).should.be.rejectedWith(EVMRevert);
            await brokenMulti.unbundleSome(_, 100, [_xyz.address]).should.be.rejectedWith(EVMRevert);
            await brokenMulti.unbundleSome(_, 100, [_abc.address]).should.be.fulfilled;
        });
    });
});

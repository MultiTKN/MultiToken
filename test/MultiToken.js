const EVMRevert = require('./helpers/EVMRevert');
const { assertRevert } = require('./helpers/assertRevert');

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

const Token = artifacts.require('Token.sol');
const BadToken = artifacts.require('BadToken.sol');
const MultiToken = artifacts.require('MultiToken.sol');

contract('MultiToken', function ([_, wallet1, wallet2, wallet3, wallet4, wallet5]) {
    let abc;
    let xyz;
    let lmn;
    let multi;

    beforeEach(async function () {
        abc = await Token.new('ABC');
        await abc.mint(_, 1000e6);
        await abc.mint(wallet1, 50e6);

        xyz = await BadToken.new('BadToken', 'XYZ', 18);
        await xyz.mint(_, 500e6);
        await xyz.mint(wallet2, 50e6);

        lmn = await Token.new('LMN');
        await lmn.mint(_, 100e6);

        multi = await MultiToken.new();
    });

    it('should failure on wrong constructor arguments', async function () {
        assertRevert(function () {
            multi.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address], [1, 1, 1], 'Multi', '1ABC_1XYZ', 18, { from: _, gas: 8000000 });
        });
        assertRevert(function () {
            multi.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address], [1], 'Multi', '1ABC_1XYZ', 18, { from: _, gas: 8000000 });
        });
        assertRevert(function () {
            multi.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address], [1, 0], 'Multi', '1ABC_0XYZ', 18, { from: _, gas: 8000000 });
        });
        assertRevert(function () {
            multi.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address], [0, 1], 'Multi', '0ABC_1XYZ', 18, { from: _, gas: 8000000 });
        });
    });

    describe('ERC228', async function () {
        it('should have correct tokensCount implementation', async function () {
            const multi2 = await MultiToken.new();
            await multi2.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address], [1, 1], 'Multi', '1ABC_1XYZ', 18, { from: _, gas: 8000000 });
            (await multi2.tokensCount.call()).should.be.bignumber.equal(2);

            const multi3 = await MultiToken.new();
            await multi3.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address, lmn.address], [1, 1, 1], 'Multi', '1ABC_1XYZ', 18, { from: _, gas: 8000000 });
            (await multi3.tokensCount.call()).should.be.bignumber.equal(3);
        });

        it('should have correct tokens implementation', async function () {
            const multi2 = await MultiToken.new();
            await multi2.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address], [1, 1], 'Multi', '1ABC_1XYZ', 18, { from: _, gas: 8000000 });
            (await multi2.tokens.call(0)).should.be.equal(abc.address);
            (await multi2.tokens.call(1)).should.be.equal(xyz.address);

            const multi3 = await MultiToken.new();
            await multi3.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address, lmn.address], [1, 1, 1], 'Multi', '1ABC_1XYZ', 18, { from: _, gas: 8000000 });
            (await multi3.tokens.call(0)).should.be.equal(abc.address);
            (await multi3.tokens.call(1)).should.be.equal(xyz.address);
            (await multi3.tokens.call(2)).should.be.equal(lmn.address);
        });

        it('should have correct getReturn implementation', async function () {
            await multi.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address], [1, 1], 'Multi', '1ABC_1XYZ', 18, { from: _, gas: 8000000 });
            (await multi.getReturn.call(abc.address, xyz.address, 100)).should.be.bignumber.equal(0);

            await abc.approve(multi.address, 1000e6);
            await xyz.approve(multi.address, 500e6);
            await multi.bundleFirstTokens(_, 1000, [1000e6, 500e6]);

            (await multi.getReturn.call(abc.address, lmn.address, 100)).should.be.bignumber.equal(0);
            (await multi.getReturn.call(lmn.address, xyz.address, 100)).should.be.bignumber.equal(0);
            (await multi.getReturn.call(lmn.address, lmn.address, 100)).should.be.bignumber.equal(0);
            (await multi.getReturn.call(abc.address, xyz.address, 100)).should.be.bignumber.not.equal(0);

            (await multi.getReturn.call(abc.address, abc.address, 100)).should.be.bignumber.equal(0);
            (await multi.getReturn.call(xyz.address, xyz.address, 100)).should.be.bignumber.equal(0);
        });

        it('should have correct change implementation for missing and same tokens', async function () {
            await multi.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address], [1, 1], 'Multi', '1ABC_1XYZ', 18, { from: _, gas: 8000000 });

            await abc.approve(multi.address, 1000e6);
            await xyz.approve(multi.address, 500e6);
            await multi.bundleFirstTokens(_, 1000, [1000e6, 500e6]);

            await multi.change(abc.address, lmn.address, 100, 0).should.be.rejectedWith(EVMRevert);
            await multi.change(lmn.address, xyz.address, 100, 0).should.be.rejectedWith(EVMRevert);
            await multi.change(lmn.address, lmn.address, 100, 0).should.be.rejectedWith(EVMRevert);

            await multi.change(abc.address, abc.address, 100, 0).should.be.rejectedWith(EVMRevert);
            await multi.change(xyz.address, xyz.address, 100, 0).should.be.rejectedWith(EVMRevert);
        });
    });

    describe('exchange 1:1', async function () {
        beforeEach(async function () {
            await multi.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address], [1, 1], 'Multi', '1ABC_1XYZ', 18, { from: _, gas: 8000000 });
            await abc.approve(multi.address, 1000e6);
            await xyz.approve(multi.address, 500e6);
            await multi.bundleFirstTokens(_, 1000, [1000e6, 500e6]);
        });

        it('should have valid prices for exchange tokens', async function () {
            (await multi.getReturn.call(abc.address, xyz.address, 10e6)).should.be.bignumber.equal(4950495);
            (await multi.getReturn.call(abc.address, xyz.address, 20e6)).should.be.bignumber.equal(9803921);
            (await multi.getReturn.call(abc.address, xyz.address, 30e6)).should.be.bignumber.equal(14563106);
            (await multi.getReturn.call(abc.address, xyz.address, 40e6)).should.be.bignumber.equal(19230769);
            (await multi.getReturn.call(abc.address, xyz.address, 50e6)).should.be.bignumber.equal(23809523);
            (await multi.getReturn.call(abc.address, xyz.address, 60e6)).should.be.bignumber.equal(28301886);
            (await multi.getReturn.call(abc.address, xyz.address, 70e6)).should.be.bignumber.equal(32710280);
            (await multi.getReturn.call(abc.address, xyz.address, 80e6)).should.be.bignumber.equal(37037037);
            (await multi.getReturn.call(abc.address, xyz.address, 90e6)).should.be.bignumber.equal(41284403);
            (await multi.getReturn.call(abc.address, xyz.address, 100e6)).should.be.bignumber.equal(45454545);

            (await multi.getReturn.call(xyz.address, abc.address, 10e6)).should.be.bignumber.equal(19607843);
            (await multi.getReturn.call(xyz.address, abc.address, 20e6)).should.be.bignumber.equal(38461538);
            (await multi.getReturn.call(xyz.address, abc.address, 30e6)).should.be.bignumber.equal(56603773);
            (await multi.getReturn.call(xyz.address, abc.address, 40e6)).should.be.bignumber.equal(74074074);
            (await multi.getReturn.call(xyz.address, abc.address, 50e6)).should.be.bignumber.equal(90909090);
            (await multi.getReturn.call(xyz.address, abc.address, 60e6)).should.be.bignumber.equal(107142857);
            (await multi.getReturn.call(xyz.address, abc.address, 70e6)).should.be.bignumber.equal(122807017);
            (await multi.getReturn.call(xyz.address, abc.address, 80e6)).should.be.bignumber.equal(137931034);
            (await multi.getReturn.call(xyz.address, abc.address, 90e6)).should.be.bignumber.equal(152542372);
            (await multi.getReturn.call(xyz.address, abc.address, 100e6)).should.be.bignumber.equal(166666666);
        });

        it('should be able to exchange tokens 0 => 1', async function () {
            (await xyz.balanceOf.call(wallet1)).should.be.bignumber.equal(0);
            await abc.approve(multi.address, 50e6, { from: wallet1 });
            await multi.change(abc.address, xyz.address, 50e6, 23809523, { from: wallet1 });
            (await xyz.balanceOf.call(wallet1)).should.be.bignumber.equal(23809523);
        });

        it('should not be able to exchange due to high min return argument', async function () {
            (await xyz.balanceOf.call(wallet1)).should.be.bignumber.equal(0);
            await abc.approve(multi.address, 50e6, { from: wallet1 });
            await multi.change(abc.address, xyz.address, 50e6, 23809523 + 1, { from: wallet1 }).should.be.rejectedWith(EVMRevert);
        });

        it('should be able to exchange tokens 1 => 0', async function () {
            (await abc.balanceOf.call(wallet2)).should.be.bignumber.equal(0);
            await xyz.approve(multi.address, 50e6, { from: wallet2 });
            await multi.change(xyz.address, abc.address, 50e6, 90909090, { from: wallet2 });
            (await abc.balanceOf.call(wallet2)).should.be.bignumber.equal(90909090);
        });

        it('should be able to buy tokens and sell back', async function () {
            (await xyz.balanceOf.call(wallet1)).should.be.bignumber.equal(0);
            await abc.approve(multi.address, 50e6, { from: wallet1 });
            await multi.change(abc.address, xyz.address, 50e6, 23809523, { from: wallet1 });

            (await abc.balanceOf.call(wallet1)).should.be.bignumber.equal(0);
            (await xyz.balanceOf.call(wallet1)).should.be.bignumber.equal(23809523);

            await xyz.approve(multi.address, 23809523, { from: wallet1 });
            await multi.change(xyz.address, abc.address, 23809523, 49999998, { from: wallet1 });

            (await abc.balanceOf.call(wallet1)).should.be.bignumber.equal(49999998);
        });
    });

    describe('exchange 2:1', async function () {
        beforeEach(async function () {
            await multi.contract.init['address[],uint256[],string,string,uint8']([abc.address, xyz.address], [2, 1], 'Multi', '2ABC_1XYZ', 18, { from: _, gas: 8000000 });
            await abc.approve(multi.address, 1000e6);
            await xyz.approve(multi.address, 500e6);
            await multi.bundleFirstTokens(_, 1000, [1000e6, 500e6]);
        });

        it('should have valid prices for exchange tokens', async function () {
            (await multi.getReturn.call(abc.address, xyz.address, 10e6)).should.be.bignumber.equal(9803921);
            (await multi.getReturn.call(abc.address, xyz.address, 20e6)).should.be.bignumber.equal(19230769);
            (await multi.getReturn.call(abc.address, xyz.address, 30e6)).should.be.bignumber.equal(28301886);
            (await multi.getReturn.call(abc.address, xyz.address, 40e6)).should.be.bignumber.equal(37037037);
            (await multi.getReturn.call(abc.address, xyz.address, 50e6)).should.be.bignumber.equal(45454545);
            (await multi.getReturn.call(abc.address, xyz.address, 60e6)).should.be.bignumber.equal(53571428);
            (await multi.getReturn.call(abc.address, xyz.address, 70e6)).should.be.bignumber.equal(61403508);
            (await multi.getReturn.call(abc.address, xyz.address, 80e6)).should.be.bignumber.equal(68965517);
            (await multi.getReturn.call(abc.address, xyz.address, 90e6)).should.be.bignumber.equal(76271186);
            (await multi.getReturn.call(abc.address, xyz.address, 100e6)).should.be.bignumber.equal(83333333);

            (await multi.getReturn.call(xyz.address, abc.address, 10e6)).should.be.bignumber.equal(9803921);
            (await multi.getReturn.call(xyz.address, abc.address, 20e6)).should.be.bignumber.equal(19230769);
            (await multi.getReturn.call(xyz.address, abc.address, 30e6)).should.be.bignumber.equal(28301886);
            (await multi.getReturn.call(xyz.address, abc.address, 40e6)).should.be.bignumber.equal(37037037);
            (await multi.getReturn.call(xyz.address, abc.address, 50e6)).should.be.bignumber.equal(45454545);
            (await multi.getReturn.call(xyz.address, abc.address, 60e6)).should.be.bignumber.equal(53571428);
            (await multi.getReturn.call(xyz.address, abc.address, 70e6)).should.be.bignumber.equal(61403508);
            (await multi.getReturn.call(xyz.address, abc.address, 80e6)).should.be.bignumber.equal(68965517);
            (await multi.getReturn.call(xyz.address, abc.address, 90e6)).should.be.bignumber.equal(76271186);
            (await multi.getReturn.call(xyz.address, abc.address, 100e6)).should.be.bignumber.equal(83333333);
        });
    });
});

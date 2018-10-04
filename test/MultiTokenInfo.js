
/* @flow */

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

const Token = artifacts.require('Token.sol');
const BadToken = artifacts.require('BadToken.sol');
const BasicMultiToken = artifacts.require('BasicMultiToken.sol');
const MultiTokenInfo = artifacts.require('MultiTokenInfo.sol');

contract('MultiTokenInfo', function ([_, wallet1, wallet2, wallet3, wallet4, wallet5]) {
    let abc;
    let xyz;
    let lmn;
    let info;

    before(async function () {
        info = await MultiTokenInfo.new();
    });

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

    it('should provide working method allTokens', async function () {
        const multi = await BasicMultiToken.new([abc.address, xyz.address], 'Multi', '1ABC_1XYZ', 18);
        (await info.allTokens.call(multi.address)).should.be.deep.equal([
            abc.address,
            xyz.address,
        ]);

        const multi2 = await BasicMultiToken.new([abc.address, xyz.address, lmn.address], 'Multi', '1ABC_1XYZ_1LMN', 18);
        (await info.allTokens.call(multi2.address)).should.be.deep.equal([
            abc.address,
            xyz.address,
            lmn.address,
        ]);
    });

    it('should provide working method allNames', async function () {
        const multi = await BasicMultiToken.new([abc.address, xyz.address], 'Multi', '1ABC_1XYZ', 18);
        (await info.allNames.call(multi.address)).map(web3.toUtf8).should.be.deep.equal([
            'Token',
            'BadToken',
        ]);

        const multi2 = await BasicMultiToken.new([abc.address, xyz.address, lmn.address], 'Multi', '1ABC_1XYZ_1LMN', 18);
        (await info.allNames.call(multi2.address)).map(web3.toUtf8).should.be.deep.equal([
            'Token',
            'BadToken',
            'Token',
        ]);
    });

    it('should provide working method allSymbols', async function () {
        const multi = await BasicMultiToken.new([abc.address, xyz.address], 'Multi', '1ABC_1XYZ', 18);
        (await info.allSymbols.call(multi.address)).map(web3.toUtf8).should.be.deep.equal([
            'ABC',
            'XYZ',
        ]);

        const multi2 = await BasicMultiToken.new([abc.address, xyz.address, lmn.address], 'Multi', '1ABC_1XYZ_1LMN', 18);
        (await info.allSymbols.call(multi2.address)).map(web3.toUtf8).should.be.deep.equal([
            'ABC',
            'XYZ',
            'LMN',
        ]);
    });

    it('should provide working method allBalances', async function () {
        const multi = await BasicMultiToken.new([abc.address, xyz.address], 'Multi', '1ABC_1XYZ', 18);
        await abc.approve(multi.address, 1000e6);
        await xyz.approve(multi.address, 500e6);
        await multi.bundleFirstTokens(_, 1000, [1000e6, 500e6]);

        (await info.allBalances.call(multi.address)).map(bn => bn.toString()).should.be.deep.equal([
            '1000000000',
            '500000000',
        ]);
    });
});

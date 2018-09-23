// @flow

const privateKey = '0x668a369e87c01da5bfca9851e6ee86d760e17ee7912d77b7dffe8e0cdf63bcb5';
const multiTokensAddresses = [
    '0x5C4fC01E5d687F1d2C627bA7DE3A59c33aEFaA35',
];

// eslint-disable-next-line max-len
const erc20ABI = [{ 'anonymous': false, 'inputs': [{ 'indexed': true, 'name': 'from', 'type': 'address' }, { 'indexed': true, 'name': 'to', 'type': 'address' }, { 'indexed': false, 'name': 'value', 'type': 'uint256' }], 'name': 'Transfer', 'type': 'event' }, { 'constant': true, 'inputs': [], 'name': 'totalSupply', 'outputs': [{ 'name': '', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': true, 'inputs': [{ 'name': 'who', 'type': 'address' }], 'name': 'balanceOf', 'outputs': [{ 'name': '', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': 'to', 'type': 'address' }, { 'name': 'value', 'type': 'uint256' }], 'name': 'transfer', 'outputs': [{ 'name': '', 'type': 'bool' }], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }];
// eslint-disable-next-line max-len
const multiABI = [{ 'constant': true, 'inputs': [], 'name': 'name', 'outputs': [{ 'name': '', 'type': 'string' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': '_spender', 'type': 'address' }, { 'name': '_value', 'type': 'uint256' }], 'name': 'approve', 'outputs': [{ 'name': '', 'type': 'bool' }], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': '_value', 'type': 'uint256' }, { 'name': 'someTokens', 'type': 'address[]' }], 'name': 'unbundleSome', 'outputs': [], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }, { 'constant': true, 'inputs': [], 'name': 'totalSupply', 'outputs': [{ 'name': '', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': '_from', 'type': 'address' }, { 'name': '_to', 'type': 'address' }, { 'name': '_value', 'type': 'uint256' }], 'name': 'transferFrom', 'outputs': [{ 'name': '', 'type': 'bool' }], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }, { 'constant': true, 'inputs': [], 'name': 'decimals', 'outputs': [{ 'name': '', 'type': 'uint8' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': '_to', 'type': 'address' }, { 'name': '_amount', 'type': 'uint256' }], 'name': 'bundle', 'outputs': [], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': '_value', 'type': 'uint256' }], 'name': 'unbundle', 'outputs': [], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }, { 'constant': true, 'inputs': [{ 'name': '', 'type': 'uint256' }], 'name': 'tokens', 'outputs': [{ 'name': '', 'type': 'address' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': '_spender', 'type': 'address' }, { 'name': '_subtractedValue', 'type': 'uint256' }], 'name': 'decreaseApproval', 'outputs': [{ 'name': '', 'type': 'bool' }], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }, { 'constant': true, 'inputs': [], 'name': 'res', 'outputs': [{ 'name': '', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': true, 'inputs': [{ 'name': '_owner', 'type': 'address' }], 'name': 'balanceOf', 'outputs': [{ 'name': '', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': true, 'inputs': [], 'name': 'symbol', 'outputs': [{ 'name': '', 'type': 'string' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': true, 'inputs': [{ 'name': '', 'type': 'address' }], 'name': 'weights', 'outputs': [{ 'name': '', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': '_to', 'type': 'address' }, { 'name': '_value', 'type': 'uint256' }], 'name': 'transfer', 'outputs': [{ 'name': '', 'type': 'bool' }], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': '_spender', 'type': 'address' }, { 'name': '_addedValue', 'type': 'uint256' }], 'name': 'increaseApproval', 'outputs': [{ 'name': '', 'type': 'bool' }], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }, { 'constant': true, 'inputs': [{ 'name': '_owner', 'type': 'address' }, { 'name': '_spender', 'type': 'address' }], 'name': 'allowance', 'outputs': [{ 'name': '', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': '_to', 'type': 'address' }, { 'name': '_amount', 'type': 'uint256' }, { 'name': '_tokenAmounts', 'type': 'uint256[]' }], 'name': 'bundleFirstTokens', 'outputs': [], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }, { 'inputs': [{ 'name': '_tokens', 'type': 'address[]' }, { 'name': '_weights', 'type': 'uint256[]' }, { 'name': '_name', 'type': 'string' }, { 'name': '_symbol', 'type': 'string' }, { 'name': '_decimals', 'type': 'uint8' }], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'constructor' }, { 'anonymous': false, 'inputs': [], 'name': 'Update', 'type': 'event' }, { 'anonymous': false, 'inputs': [{ 'indexed': true, 'name': '_fromToken', 'type': 'address' }, { 'indexed': true, 'name': '_toToken', 'type': 'address' }, { 'indexed': true, 'name': '_changer', 'type': 'address' }, { 'indexed': false, 'name': '_amount', 'type': 'uint256' }, { 'indexed': false, 'name': '_return', 'type': 'uint256' }], 'name': 'Change', 'type': 'event' }, { 'anonymous': false, 'inputs': [{ 'indexed': true, 'name': 'minter', 'type': 'address' }, { 'indexed': false, 'name': 'value', 'type': 'uint256' }], 'name': 'Bundle', 'type': 'event' }, { 'anonymous': false, 'inputs': [{ 'indexed': true, 'name': 'burner', 'type': 'address' }, { 'indexed': false, 'name': 'value', 'type': 'uint256' }], 'name': 'Unbundle', 'type': 'event' }, { 'anonymous': false, 'inputs': [{ 'indexed': true, 'name': 'owner', 'type': 'address' }, { 'indexed': true, 'name': 'spender', 'type': 'address' }, { 'indexed': false, 'name': 'value', 'type': 'uint256' }], 'name': 'Approval', 'type': 'event' }, { 'anonymous': false, 'inputs': [{ 'indexed': true, 'name': 'from', 'type': 'address' }, { 'indexed': true, 'name': 'to', 'type': 'address' }, { 'indexed': false, 'name': 'value', 'type': 'uint256' }], 'name': 'Transfer', 'type': 'event' }, { 'constant': true, 'inputs': [], 'name': 'tokensCount', 'outputs': [{ 'name': 'count', 'type': 'uint16' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': true, 'inputs': [{ 'name': '_tokenIndex', 'type': 'uint16' }], 'name': 'tokens', 'outputs': [{ 'name': 'tokenAddress', 'type': 'address' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': true, 'inputs': [{ 'name': '_fromToken', 'type': 'address' }, { 'name': '_toToken', 'type': 'address' }, { 'name': '_amount', 'type': 'uint256' }], 'name': 'getReturn', 'outputs': [{ 'name': 'returnAmount', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'view', 'type': 'function' }, { 'constant': false, 'inputs': [{ 'name': '_fromToken', 'type': 'address' }, { 'name': '_toToken', 'type': 'address' }, { 'name': '_amount', 'type': 'uint256' }, { 'name': '_minReturn', 'type': 'uint256' }], 'name': 'change', 'outputs': [{ 'name': 'returnAmount', 'type': 'uint256' }], 'payable': false, 'stateMutability': 'nonpayable', 'type': 'function' }];

const Web3 = require('web3');
const fetch = require('node-fetch');

process.on('unhandledRejection', (reason, p) => {
    console.log('Unhandled Rejection at: Promise', p, 'reason:', reason);
});

(async function () {
    // const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
    // const web3 = new Web3(new Web3.providers.HttpProvider('https://ropsten.infura.io/'));
    // const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:8546'));
    const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://ropsten.infura.io/ws'));
    // const web3 = new Web3(new Web3.providers.HttpProvider('https://mainnet.infura.io/GOGw1ym3Hu5NytWUre29'));

    if (privateKey.length !== 66) {
        console.log('privateKey should be of length 66.' + (privateKey.length === 64 ? ' Prepend with "0x".' : ''));
        return;
    }
    const account = web3.eth.accounts.privateKeyToAccount(privateKey);
    console.log('account = ' + account.address);

    const bancorData = await (await fetch('https://api.bancor.network/0.1/currencies/tokens?limit=100&skip=0')).json();
    const bancorTokens = bancorData.data.currencies.page;
    const bancorPriceByToken = {};
    const bancorCurrencyIdByToken = {};
    for (let bancorToken of bancorTokens) {
        // console.log(bancorToken);
        bancorPriceByToken[bancorToken.details.contractAddress] = bancorToken.price;
        bancorCurrencyIdByToken[bancorToken.details.contractAddress] = bancorToken.originalCurrencyId;
    }

    for (let multiTokenAddress of multiTokensAddresses) {
        const multiToken = new web3.eth.Contract(multiABI, multiTokenAddress);
        const tokensCount = await multiToken.methods.tokensCount().call();

        const tokens = await Promise.all(
            Array.from({ length: tokensCount }, (x, i) => multiToken.methods.tokens(i).call())
        );

        // Token weights
        const weights = await Promise.all(
            tokens.map(ta => multiToken.methods.weights(ta).call())
        );
        const tokenWeights = new Map(weights.map((w, i) => [tokens[i], w]));

        // Token amounts
        const amounts = await Promise.all(
            Array.from(tokens, ta => new web3.eth.Contract(erc20ABI, ta))
                .map(t => t.methods.balanceOf(multiTokenAddress).call())
        );
        const tokenAmounts = new Map(amounts.map((a, i) => [tokens[i], a]));

        // Find profit n^2 (need optimize)
        let bestTokenA;
        let bestTokenB;
        let bestRatio;
        for (let tokenAddressA of tokens) {
            for (let tokenAddressB of tokens) {
                if (tokenAddressA === tokenAddressB) {
                    continue;
                }

                const mutiTokenPrice = tokenAmounts[tokenAddressA] * tokenWeights[tokenAddressA] / (tokenAmounts[tokenAddressB] * tokenWeights[tokenAddressB]);
                const bancorTokenPrice = bancorPriceByToken[tokenAddressA] / bancorPriceByToken[tokenAddressB];
                if (mutiTokenPrice / bancorTokenPrice > bestRatio) {
                    bestRatio = mutiTokenPrice / bancorTokenPrice;
                    bestTokenA = tokenAddressA;
                    bestTokenB = tokenAddressB;
                }
            }
        }

        // If more than 1%
        // if (bestRatio > 1.01) {
        bestRatio = 1.01;
        bestTokenA = tokens[0];
        bestTokenB = tokens[1];
        const bestTokenAmountA = tokenAmounts.get(bestTokenA);
        const bestTokenAmountB = tokenAmounts.get(bestTokenB);

        const percent = (bestRatio - 1) / 2;
        const amount = bestTokenAmountA * percent;
        const minimumReturn = bestTokenAmountB - bestTokenAmountB / (1 + percent);
        console.log(amount, minimumReturn);
        // const multiGas = await multiToken.methods.change(bestTokenB, bestTokenA, amount, minimumReturn).estimateGas();

        const fromCurrencyId = bancorCurrencyIdByToken[bestTokenB];
        const toCurrencyId = bancorCurrencyIdByToken[bestTokenA];
        const ownerAddress = account.address;
        const json = await (await fetch('https://api.bancor.network/0.1/currencies/convert' +
                '?fromCurrencyId=' + fromCurrencyId +
                '&toCurrencyId=' + toCurrencyId +
                '&amount=' + amount +
                '&minimumReturn=' + minimumReturn +
                '&ownerAddress=' + ownerAddress)).json();
        console.log(json);
    }

    // var prevBalance = 0;

    // web3.eth.subscribe('newBlockHeaders', async function (error, blockHeader) {
    //     if (error) {
    //         console.log('error: ' + error);
    //         return;
    //     }

    //     console.log('================================================================');
    //     console.log('block number = ' + blockHeader.number);

    //     const [
    //         balance,
    //         nonce,
    //     ] = (await Promise.all([
    //         web3.eth.getBalance(account.address),
    //         web3.eth.getTransactionCount(account.address),
    //     ])).map(v => web3.utils.toBN(v));

    //     // const balance = web3.utils.toBN(await web3.eth.getBalance(account.address));
    //     console.log('balance = ' + balance);
    //     // const nonce = await web3.eth.getTransactionCount(account.address);
    //     console.log('nonce = ' + nonce);

    //     if (balance.toString() == prevBalance) {
    //         console.log('Skipping known balance');
    //         return;
    //     }
    //     prevBalance = balance.toString();

    //     const gas = web3.utils.toBN('21000');
    //     const maxGasPrice = balance.div(gas);
    //     console.log('maxGasPrice = ' + maxGasPrice.toString());
    //     const bestGasPrice = maxGasPrice.mul(web3.utils.toBN('1000')).div(web3.utils.toBN('1045'));
    //     console.log('bestGasPrice = ' + bestGasPrice.toString());
    //     const value = balance.sub(bestGasPrice.mul(gas));
    //     console.log('value = ' + value.toString());

    //     // If less then 0.1 Gwei
    //     if (bestGasPrice.lt(web3.utils.toBN('100000000'))) {
    //         console.log('Not enough balance to pay tx fee');
    //         return;
    //     }

    //     const txData = {
    //         from: account.address,
    //         to: wallet,
    //         value: value,
    //         gasPrice: bestGasPrice,
    //         gas: gas,
    //         nonce: nonce,
    //     };
    //     const transaction = new Tx(txData);
    //     transaction.sign(new Buffer(privateKey.substr(2), 'hex'));
    //     const serializedTx = transaction.serialize().toString('hex');
    //     web3.eth.sendSignedTransaction('0x' + serializedTx).on('transactionHash', function (hash) {
    //         console.log('transaction = https://etherscan.io/tx/' + hash);
    //     });
    // }).on('data', async function (blockHeader) {
    // });
})();

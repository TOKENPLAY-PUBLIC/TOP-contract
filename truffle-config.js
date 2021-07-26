const HDWalletProvider = require('@truffle/hdwallet-provider');

const fs = require('fs');
const privateKeys = fs.readFileSync('.secret').toString().split('\n');

const testNetwork =
    'https://ropsten.infura.io/v3/f2473914890349138c8b03e3ef79d165';

module.exports = {
    /**
     * Networks define how you connect to your ethereum client and let you set the
     * defaults web3 uses to send transactions. If you don't specify one truffle
     * will spin up a development blockchain for you on port 9545 when you
     * run `develop` or `test`. You can ask a truffle command to use a specific
     * network from the command line, e.g
     *
     * $ truffle test --network <network-name>
     */

    networks: {
        // Useful for testing. The `development` name is special - truffle uses it by default
        // if it's defined here and no other network is specified at the command line.
        // You should run a client (like ganache-cli, geth or parity) in a separate terminal
        // tab if you use this network and you must also set the `host`, `port` and `network_id`
        // options below to some value.
        //
        development: {
            host: '127.0.0.1', // Localhost (default: none)
            port: 8545, // Standard Ethereum port (default: none)
            network_id: '*', // Any network (default: none)
        },

        eth_testnet: {
            provider: () =>
                new HDWalletProvider(privateKeys, testNetwork, 0, 1),
            network_id: 3, // Ropsten's id
            gas: 5500000, // Ropsten has a lower block limit than mainnet
            confirmations: 2, // # of confs to wait between deployments. (default: 0)
            timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
            skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
        },

        bsc_testnet: {
            provider: () =>
                new HDWalletProvider(
                    privateKeys,
                    `https://data-seed-prebsc-2-s1.binance.org:8545/`,
                    0,
                    1
                ),
            network_id: 97,
            confirmations: 2,
            gas: 5500000,
            timeoutBlocks: 200,
            skipDryRun: true,
        },

        bsc_mainnet: {
            provider: () =>
                new HDWalletProvider(
                    privateKeys,
                    `https://bsc-dataseed.binance.org/`,
                    0,
                    1
                ),
            network_id: 56,
            confirmations: 2,
            gas: 2000000,
            timeoutBlocks: 200,
            skipDryRun: true,
        },
    },

    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },
    plugins: [
        'truffle-plugin-verify'
    ],
    api_keys: {
        bscscan: '4F91FHBBB5XICNI9HX5UMTTN19G3N7X4N2'
    },
    compilers: {
        solc: {
            version: '0.8.3', // Fetch exact version from solc-bin (default: truffle's version)
            docker: false, // Use "0.5.1" you've installed locally with docker (default: false)
            settings: {
                // See the solidity docs for advice about optimization and evmVersion
                optimizer: {
                    enabled: true,
                    runs: 200,
                },
            },
        },
    },
};
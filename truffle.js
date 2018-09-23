module.exports = {
    networks: {
        development: {
            host: "localhost",
            port: 9545,
            network_id: "*",
            gas: 8000000
        },
        coverage: {
            host: "localhost",
            port: 8555,
            network_id: "*",
            gas: 0xfffffffffff
        },
        profiler: {
            host: "localhost",
            port: 8555,
            network_id: "*",
            gas: 0xfffffffffff
        }
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    }
};

module.exports = {
    networks: {
        shasta: {
            from: 'T9yq8VtjCF7H6HXha3TUcBZnGYFnG59w4V',
            privateKey: process.env.PRIVATE_KEY_SHASTA,
            consume_user_resource_percent: 30,
            userFeePercentage: 50,
            feeLimit: 1e8,
            fullHost: 'https://api.shasta.trongrid.io',
            network_id: '2'
        },
        compilers: {
            solc: {
                version: '0.5.8'
            }
        }
    }
}

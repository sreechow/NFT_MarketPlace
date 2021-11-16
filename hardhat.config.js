require("@nomiclabs/hardhat-waffle");
const fs = require('fs')
const keyData = fs.readFileSync('./p_key.txt', {
  encoding:'utf-8', flag:'r'
})

module.exports = {
  defaultNetwork: 'hardhat',
  networks:{
    hardhat:{
      chainId: 1337 // waht's this standard?
    },
    mumbai:{ //test net
      url:'https://polygon-mumbai.infura.io/v3/79dd4f5f9c9c41538583399592b7f7d0',
      accounts: [keyData]
    },
    mainnet:{ //main net
      url:'https://mainnet.infura.io/v3/79dd4f5f9c9c41538583399592b7f7d0',
      accounts: [keyData]
    }
  },
  solidity: {
    version : "0.8.4",
    settings:{
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};

require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

module.exports = {
  solidity: "0.8.17",
  gasReporter: {
      enabled: true,
      showTimeSpent: false,
  },
  networks: {
      goerli: {
          url: `https://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
          accounts: [process.env.DEPLOYER_PRIVATE_KEY]
      }
  },
  etherscan: {
      apiKey: process.env.ETHERSCANS_API_KEY,
  }
};

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter"

const config: HardhatUserConfig = {
  solidity: {
    version:"0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 21,
    enabled: true,    
    token:'ETH',
    gasPriceApi:'https://api.etherscan.io/api?module=proxy&action=eth_gasPrice'
  },
  
};


export default config;

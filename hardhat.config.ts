import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-web3";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "@typechain/hardhat";
import { resolve } from "path";
import { config as dotenvConfig } from "dotenv";
import bigNumber from "bignumber.js";

dotenvConfig({ path: resolve(__dirname, "./.env") });

const chainIds = {
  ganache: 1337,
  hardhat: 31337,
  mainnet: 1,
  avalanche: 43114,
  polygon: 137,
  arbitrum: 42161,
  optimism: 10,
  fantom: 250,
};

const alchemyApiKey = process.env.ALCHEMY_API_KEY;
if (!alchemyApiKey) {
  throw new Error("Please set your ALCHEMY_API_KEY in a .env file");
}

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const mnemonic =
  process.env.MNEMONIC ??
  "test test test test test test test test test test test junk";

const networkGasPriceConfig: Record<string, number> = {
  polygon: 40,
  mumbai: 300,
  goerli: 0.01,
  cronos: 5000,
};

function createConfig(network: string) {
  return {
    url: getNetworkUrl(network),
    accounts: !!PRIVATE_KEY ? [`0x${PRIVATE_KEY}`] : { mnemonic },
    gasPrice: new bigNumber(networkGasPriceConfig[network])
      .multipliedBy(1e9)
      .toNumber(), // Update the mapping above
  };
}

function getNetworkUrl(networkType: string) {
  if (networkType === "cronos") return "https://evm-t3.cronos.org";
  if (networkType === "goerli")
    return `https://eth-goerli.g.alchemy.com/v2/${alchemyApiKey}`;
  else if (networkType === "mumbai")
    return `https://polygon-mumbai.g.alchemy.com/v2/${alchemyApiKey}`;
  else if (networkType === "polygon")
    return `https://polygon-mainnet.g.alchemy.com/v2/${alchemyApiKey}`;
  else return `https://eth-goerli.g.alchemy.com/v2/${alchemyApiKey}`;
}

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          viaIR: true,
        },
      },
    ],
  },
  networks: {
    hardhat: {
      accounts: {
        mnemonic,
      },
      chainId: chainIds.hardhat,
      forking: {
        url: String(getNetworkUrl("goerli")),
        // blockNumber: 8117377, // goerli
      },
    },
    mumbai: createConfig("mumbai"),
    polygon: createConfig("polygon"),
    goerli: createConfig("goerli"),
    cronos: createConfig("cronos"),
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
  etherscan: {
    apiKey: {
      polygon: String(process.env.POLY_ETHSCAN_KEY),
    },
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
  mocha: {
    timeout: 10000 * 1000, // 10,000 seconds
  },
};

export default config;

import { ethers } from "hardhat";
import { SignerWithAddress } from "hardhat-deploy-ethers/signers";
import { liquidityPool } from "../typechain/contracts";
import { Contract } from "ethers";
import { nftManager } from "../typechain/contracts/markets/uc";

async function main() {
  const wethAddr = "0xCCa7d1416518D095E729904aAeA087dBA749A4dC";
  const usdcAddr = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074";
  const daiAddr = "0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33";
  const wbtcAddr = "0xf4423F4152966eBb106261740da907662A3569C5";

  const LiquidityPoolDataProvider = await ethers.getContractAt(
    "LiquidityPoolDataProvider",
    "0xcA2EAAd424F65715082D3F0c5fE0135675bd58B5"
  );

  let data = await LiquidityPoolDataProvider.getTokenUtilization(usdcAddr);
  console.log((data / 1e6).toString() + '%');
}

main();

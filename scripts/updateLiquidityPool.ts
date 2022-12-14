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

  const proxyAdminAddr = "0x8D21F853c369222AF72F550caec5D3D84d5297A8";
  const liquidityPoolAddr = "0xa7352a773a946f498d9d6b848859E7e9215Fac83";
  const ocAddr = "0x1E2aEA81Fa87265c33330ACC5079D726972c8Fd5";
  const ucFactoryAddr = "0xEBb31e72CF95DC59525Db0301D14Ce20fF94D5c4";

  const LiquidityPool = await ethers.getContractFactory("LiquidityPoolImplementation");
  const liquidityPool = await LiquidityPool.deploy(
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr,
    ocAddr,
    ucFactoryAddr
  );
  await liquidityPool.deployed();
  console.log("Liquidity pool implementation deployed:", liquidityPool.address);

  const ProxyAdmin = await ethers.getContractAt(
    "OrbitProxyAdmin",
    proxyAdminAddr
  );
  const tx = await ProxyAdmin.upgrade(liquidityPoolAddr, liquidityPool.address);
  await tx.wait();
  console.log("Liquidity pool upgraded");
}

main();

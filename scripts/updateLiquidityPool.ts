import { ethers } from "hardhat";
import { SignerWithAddress } from "hardhat-deploy-ethers/signers";
import { liquidityPool } from "../typechain/contracts";
import { Contract } from "ethers";
import { nftManager } from "../typechain/contracts/markets/uc";

async function main() {
  const [deployer] = await ethers.getSigners();
  // goerli
  const aaveV2LendingPool = "0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210";
  const aaveV2FallbackOracle = "0x0F9d5ED72f6691E47abe2f79B890C3C33e924092";
  const aaveV2DataProvider = "0x927F584d4321C1dCcBf5e2902368124b02419a1E";

  const aaveV2FaucetAddr = "0x681860075529352da2C94082Eb66c59dF958e89C";

  const wethAddr = "0xCCa7d1416518D095E729904aAeA087dBA749A4dC";
  const usdcAddr = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074";
  const daiAddr = "0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33";
  const wbtcAddr = "0xf4423F4152966eBb106261740da907662A3569C5";

  const wethAmount = ethers.utils.parseUnits("10000", "18");
  const usdcAmount = ethers.utils.parseUnits("10", "6");
  const daiAmount = ethers.utils.parseUnits("1000000", "18");
  const wbtcAmount = ethers.utils.parseUnits("100", "8");

  const proxyAdminAddr = "0x8D21F853c369222AF72F550caec5D3D84d5297A8";
  const oracleAddr = "0x0b45FF6ED53B06989A79820521e61d76b9257d4c";
  const liquidityPoolAddr = "0xa7352a773a946f498d9d6b848859E7e9215Fac83";
  const ocAddr = "0x1E2aEA81Fa87265c33330ACC5079D726972c8Fd5";
  const ucFactoryAddr = "0xEBb31e72CF95DC59525Db0301D14Ce20fF94D5c4";
  const nftManagerAddr = "0x908c0b69d8caeAc73f48f256E2954c2ca8F9198a";
  const aaveInteractorAddr = "0x74b1A0240e9bb8758F0D28dbe333200799a78B06";
  const faucetAddr = "0xb74fFDAd0b9dcc6042B8B5c5D4639998EF99D1eB";

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

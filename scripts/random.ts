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

  const proxyAdminAddr = "0x4AfAE2d0eF84F45f4433ef8e8c2862D2eC25379F";
  const oracleAddr = "0xfAC94B0305f465bc90eBBC3578eD195767D9fF68";
  const liquidityPoolAddr = "0xDd1FA8f06a97721478Db9f1aC63Da7Cd9abBBF71";
  const ocAddr = "0xA7aF2FBABf8406DD5C53F1b258eeeC7C5435541D";
  const ucWalletAddr = "0x6457ed779168357484F660Ba2835a3b3e7d29462";
  const ucFactoryAddr = "0x216C81a5ACdFCBef845321469ADe701bC3628b9a";
  const nftManagerAddr = "0x397897D80aA543C8dA83ACD6098485f9FB2d8eB9";
  const aaveInteractorAddr = "0x9f5E978d808870ff353C95B974121A1E08D66759";
  const faucetAddr = "0x4Ee1393353ec1b95Bb6d254B00EA3D4294B9b77C";

  // const myWallet = "0x1Ef1C9f892fe7F4EeA897948F2A2A900A6836Cea";

  // const Wallet = await ethers.getContractAt("UCWalletImplementation", myWallet);
  // let data = await Wallet.supplyToLiquidityPool(usdcAddr, usdcAmount, true);
  // await data.wait();
  // console.log(data);

  // const NftManager = await ethers.getContractAt(
  //   "NftManagerImplementation",
  //   nftManagerAddr
  // );
  // const data = await NftManager.getTokenIdToCapsule(1);
  // console.log(data);
  // await NftManager.mint(deployer.address);

  // const amount = ethers.utils.parseUnits("10", "6");

  //   const usdcToken = await ethers.getContractAt("IERC20", usdcAddr);
  //   await usdcToken.approve(nftManagerAddr, amount);

  // await NftManager.borrowToWallet(1, usdcAddr, amount);

  // const Faucet = await ethers.getContractAt("Faucet", faucetAddr);

  // const OC = await ethers.getContractFactory("OCImplementation");
  // let oc = await OC.deploy(
  //   liquidityPoolAddr,
  //   oracleAddr,
  //   wethAddr,
  //   usdcAddr,
  //   daiAddr,
  //   wbtcAddr
  // );
  // await oc.deployed();
  // console.log("OC deployed at:", oc.address);

  // const NftManager = await ethers.getContractFactory(
  //   "NftManagerImplementation"
  // );
  // let nftManager = await NftManager.deploy(ucWalletAddr, liquidityPoolAddr);
  // await nftManager.deployed();
  // console.log("Nft Manager Implementation deployed at:", nftManager.address);

  // const ProxyAdmin = await ethers.getContractAt(
  //   "OrbitProxyAdmin",
  //   proxyAdminAddr
  // );
  // await ProxyAdmin.upgrade(ocAddr, oc.address);
  // console.log("OC upgraded");

  const UIDataProvider = await ethers.getContractFactory("UIDataProvider");
  let uiDataProvider = await UIDataProvider.deploy(
    liquidityPoolAddr,
    ocAddr,
    nftManagerAddr,
    oracleAddr,
    aaveV2DataProvider,
    ucFactoryAddr,
    aaveV2LendingPool,
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr
  );
  await uiDataProvider.deployed();
  console.log("UI data provider deployed at:", uiDataProvider.address);

  // let data = await uiDataProvider.getPrices();
  // console.log("Prices:", data);

  // data = await uiDataProvider.getUserBalances(deployer.address);
  // console.log("Balances:", data);

  // data = await uiDataProvider.getLiquidityPoolData();
  // console.log("Liquidity Pool data:", data);

  // data = await uiDataProvider.getAavePoolData();
  // console.log("Aave Pool data:", data);

  // data = await uiDataProvider.getUserOCData(deployer.address);
  // console.log("OC data:", data);

  let data = await uiDataProvider.getUserNftsData('0x8FB818185793B8780bD67328aEA01f0ce1aaAD08');
  console.log("Nft data:", data);
  // let uiDataProvider = await UIDataProvider.deploy(
  //   liquidityPoolAddr,
  //   ocAddr,
  //   nftManagerAddr,
  //   oracleAddr,
  //   aaveV2DataProvider,
  //   ucFactoryAddr,
  //   aaveV2LendingPool,
  //   wethAddr,
  //   usdcAddr,
  //   daiAddr,
  //   wbtcAddr
  // );
  // await uiDataProvider.deployed();
  // console.log("UI data provider deployed at:", uiDataProvider.address);
}

main();

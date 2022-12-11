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
  const usdcAmount = ethers.utils.parseUnits("1000000", "6");
  const daiAmount = ethers.utils.parseUnits("1000000", "18");
  const wbtcAmount = ethers.utils.parseUnits("100", "8");

  const proxyAdminAddr = "0x1Db2876d8Ca8bAc908125f0CC619b62a29c2B7a5";
  const oracleAddr = "0xAddFf637BA443b638e2f9dF37C9AC673e48f6670";
  const liquidityPoolAddr = "0xEf22baFF6165601CAe1C20901EeA1Eb5FCb9c8D4";
  const ocAddr = "0x604c977A3861e8770b82ec4d7Cabb874a37bB848";
  const ucFactoryAddr = "0x819231532AEaf50fE0a85309F9C62cf27725e8Ee";
  const nftManagerAddr = "0xb157dA711b23693d76EC117904d9d2df4494c3CB";
  const aaveInteractorAddr = "0x0A53a903BE5873F8735bbED37e5b7C66D61C69a0";
  const ucWalletAddr = "0x869310Bdf1C86eB34c605d076e5C2d35Cb794086";
  const faucetAddr = "0x16895aEF0445F72872524Cc0D10C50FA5C19a50a";

  //   const myWallet = "0x1Ef1C9f892fe7F4EeA897948F2A2A900A6836Cea";

  //   const Wallet = await ethers.getContractAt("UCWalletImplementation", myWallet)
  //   let data = await Wallet.walletData();
  //   console.log(data);

  //   const NftManager = await ethers.getContractAt(
  //     "NftManagerImplementation",
  //     nftManagerAddr
  //   );
  // await NftManager.mint(deployer.address);

  // const amount = ethers.utils.parseUnits("10", "6");

  //   const usdcToken = await ethers.getContractAt("IERC20", usdcAddr);
  //   await usdcToken.approve(nftManagerAddr, amount);

  // await NftManager.borrowToWallet(1, usdcAddr, amount);

  // const Faucet = await ethers.getContractAt("Faucet", faucetAddr);

  //   const Wallet = await ethers.getContractFactory("UCWalletImplementation");
  //   let wallet = await Wallet.deploy(
  //     liquidityPoolAddr,
  //     oracleAddr,
  //     aaveV2DataProvider,
  //     aaveInteractorAddr,
  //     wethAddr,
  //     usdcAddr,
  //     daiAddr,
  //     wbtcAddr
  //   );
  //   await wallet.deployed();
  //   console.log("Wallet deployed at:", wallet.address);

  const NftManager = await ethers.getContractFactory(
    "NftManagerImplementation"
  );
  let nftManager = await NftManager.deploy(ucWalletAddr, liquidityPoolAddr);
  await nftManager.deployed();
  console.log("Nft Manager Implementation deployed at:", nftManager.address);

  const ProxyAdmin = await ethers.getContractAt(
    "OrbitProxyAdmin",
    proxyAdminAddr
  );
  await ProxyAdmin.upgrade(nftManagerAddr, nftManager.address);
  console.log("Wallet upgraded");

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
}

main();

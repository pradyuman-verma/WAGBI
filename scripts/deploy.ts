import { ethers } from "hardhat";

async function main() {
  const [signer] = await ethers.getSigners();
  const aaveV2FallbackOracle = "0x0F9d5ED72f6691E47abe2f79B890C3C33e924092";
  const wethAddr = "0xCCa7d1416518D095E729904aAeA087dBA749A4dC";
  const usdcAddr = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074";
  const daiAddr = "0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33";
  const wbtcAddr = "0xf4423F4152966eBb106261740da907662A3569C5";
  const ENTRY = "0x2DF1592238420ecFe7f2431360e224707e77fA0E";
  const aaveData = "0x927F584d4321C1dCcBf5e2902368124b02419a1E";

  const Poop = await ethers.getContractFactory("LiquidityPoolImplementation");
  const poop = await Poop.deploy(
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr,
    aaveV2FallbackOracle,
    aaveV2FallbackOracle
  );
  await poop.deployed();

  const Pool = await ethers.getContractFactory("LiquidityPool");
  const pool = await Pool.deploy(poop.address, signer.address, "0x");
  await pool.deployed();

  console.log("Liquidity pool proxy deployed at", pool.address);

  const Oracle = await ethers.getContractFactory("Oracle");
  const oracle = await Oracle.deploy(aaveV2FallbackOracle);
  await oracle.deployed();

  console.log("Oracle deployed at", oracle.address);

  const OC = await ethers.getContractFactory("OCMarket");
  const oc = await OC.deploy(
    pool.address,
    oracle.address,
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr
  );
  await oc.deployed();

  console.log("OC deployed at", oc.address);

  const Wallet = await ethers.getContractFactory("WagbiWallet");
  const wallet = await Wallet.deploy(
    ENTRY, // entry point
    pool.address, // LP
    oracle.address, // oracle
    aaveData, // aave data provider,
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr
  );
  await wallet.deployed();

  console.log("wallet deployed at", wallet.address);

  const Factory = await ethers.getContractFactory("UCWalletFactory");
  const factory = await Factory.deploy(
    pool.address,
    wallet.address // wallet
  );
  await factory.deployed();

  console.log("factory deployed at", factory.address);

  const Poola = await ethers.getContractFactory("LiquidityPoolImplementation");
  const poola = await Poola.deploy(
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr,
    oc.address,
    factory.address
  );
  await poola.deployed();

  console.log("Poola deployed at", poola.address);

  await pool.upgradeTo(poola.address);
  console.log("Implementation updated!");

  const Resolver = await ethers.getContractFactory("UIDataProvider");
  const resolver = await Resolver.deploy(
    pool.address,
    oc.address,
    oracle.address,
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr
  );
  await resolver.deployed();

  console.log("Resolver deployed at", resolver.address);

  create(factory.address, signer);
}

main();

import { wrapProvider } from "@account-abstraction/sdk";
// import { ethers } from "ethers";
import { UCWalletFactory__factory, WagbiWallet__factory } from "../typechain";
// const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545/");
// const signer = provider.getSigner();

// const ENTRY_POINT = "0x2DF1592238420ecFe7f2431360e224707e77fA0E";

const create = async (FACTORY_ADDR: string, signer: any) => {
  const Factory = new ethers.Contract(
    FACTORY_ADDR,
    UCWalletFactory__factory.abi
  );

  const addr = await signer.getAddress();
  const tx = await Factory.connect(signer).create(addr);
  await tx.wait();

  let walletAddress = await Factory.connect(signer).authToWallet(addr, 0);
  console.log(
    "🚀 ~ file: deploy.ts:127 ~ create ~ walletAddress",
    walletAddress
  );
  //   for (let i = 0; i < walletAddress.length; i++) {
  //     const tx = {
  //       from: addr,
  //       to: walletAddress[i],
  //       value: ethers.utils.parseEther("10"),
  //       nonce: provider.getTransactionCount(addr, "latest"),
  //       gasLimit: ethers.utils.hexlify(100000), // 100000
  //       gasPrice: 1e9 * 10,
  //     };

  //     await signer.sendTransaction(tx);
  //   }
};

// const supply = async (token: string, amount: string) => {
//   const config = {
//     chainId: await provider.getNetwork().then((net) => net.chainId),
//     entryPointAddress: ENTRY_POINT,
//     bundlerUrl: "http://localhost:3000/rpc",
//   };

//   const Factory = new ethers.Contract(
//     FACTORY_ADDR,
//     UCWalletFactory__factory.abi,
//     provider
//   );
//   const aaProvider = await wrapProvider(provider, config, signer);
//   let walletAddress = await Factory.authToWallet(signer._address);

//   const wagbiWallet = new ethers.Contract(
//     walletAddress[walletAddress.length - 1],
//     WagbiWallet__factory.abi,
//     aaProvider
//   );
//   await wagbiWallet.supplyToWallet(token, amount);
// };

// const supplyToPool = async (token: string, amount: string) => {
//   const config = {
//     chainId: await provider.getNetwork().then((net) => net.chainId),
//     entryPointAddress: ENTRY_POINT,
//     bundlerUrl: "http://localhost:3000/rpc",
//   };

//   const Factory = new ethers.Contract(
//     FACTORY_ADDR,
//     UCWalletFactory__factory.abi,
//     provider
//   );
//   const aaProvider = await wrapProvider(provider, config, signer);
//   let walletAddress = await Factory.authToWallet(signer._address);

//   const wagbiWallet = new ethers.Contract(
//     walletAddress[walletAddress.length - 1],
//     WagbiWallet__factory.abi,
//     aaProvider
//   );
//   await wagbiWallet.supplyToLiquidityPool(token, amount, true);
// };

// const withdrawFromPool = async (token: string, amount: string) => {
//   const config = {
//     chainId: await provider.getNetwork().then((net) => net.chainId),
//     entryPointAddress: ENTRY_POINT,
//     bundlerUrl: "http://localhost:3000/rpc",
//   };

//   const Factory = new ethers.Contract(
//     FACTORY_ADDR,
//     UCWalletFactory__factory.abi,
//     provider
//   );
//   const aaProvider = await wrapProvider(provider, config, signer);
//   let walletAddress = await Factory.authToWallet(signer._address);

//   const wagbiWallet = new ethers.Contract(
//     walletAddress[walletAddress.length - 1],
//     WagbiWallet__factory.abi,
//     aaProvider
//   );
//   await wagbiWallet.withdrawFromLiquidityPool(
//     token,
//     amount,
//     wagbiWallet.address
//   );
// };

// const borrow = async (token: string, amount: string) => {
//   const config = {
//     chainId: await provider.getNetwork().then((net) => net.chainId),
//     entryPointAddress: ENTRY_POINT,
//     bundlerUrl: "http://localhost:3000/rpc",
//   };

//   const Factory = new ethers.Contract(
//     FACTORY_ADDR,
//     UCWalletFactory__factory.abi,
//     provider
//   );
//   const aaProvider = await wrapProvider(provider, config, signer);
//   let walletAddress = await Factory.authToWallet(signer._address);

//   const wagbiWallet = new ethers.Contract(
//     walletAddress[walletAddress.length - 1],
//     WagbiWallet__factory.abi,
//     aaProvider
//   );
//   await wagbiWallet.borrowToWallet(token, amount);
// };

// const payback = async (token: string, amount: string) => {
//   const config = {
//     chainId: await provider.getNetwork().then((net) => net.chainId),
//     entryPointAddress: ENTRY_POINT,
//     bundlerUrl: "http://localhost:3000/rpc",
//   };

//   const Factory = new ethers.Contract(
//     FACTORY_ADDR,
//     UCWalletFactory__factory.abi,
//     provider
//   );
//   const aaProvider = await wrapProvider(provider, config, signer);
//   let walletAddress = await Factory.authToWallet(signer._address);

//   const wagbiWallet = new ethers.Contract(
//     walletAddress[walletAddress.length - 1],
//     WagbiWallet__factory.abi,
//     aaProvider
//   );
//   await wagbiWallet.payback(token, amount, true);
// };

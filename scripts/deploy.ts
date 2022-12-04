import { ethers } from "hardhat";

async function main() {
  const [signer] = await ethers.getSigners();
  const aaveV2LendingPool = "0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210";
  const aaveV2FallbackOracle = "0x0F9d5ED72f6691E47abe2f79B890C3C33e924092";
  const wethAddr = "0xCCa7d1416518D095E729904aAeA087dBA749A4dC";
  const usdcAddr = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074";
  const daiAddr = "0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33";
  const wbtcAddr = "0xf4423F4152966eBb106261740da907662A3569C5";
  const ENTRY = "0x2DF1592238420ecFe7f2431360e224707e77fA0E";
  const aaveDataProvider = "0x927F584d4321C1dCcBf5e2902368124b02419a1E";

  const AavePlanet = await ethers.getContractFactory("AavePlanet");
  const aavePlanet = await AavePlanet.deploy(
    aaveV2LendingPool,
    aaveDataProvider,
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr
  );
  await aavePlanet.deployed();

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
    aaveDataProvider, // aave data provider,
    aavePlanet.address,
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
    aaveDataProvider,
    factory.address,
    aaveV2LendingPool,
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr
  );
  await resolver.deployed();

  console.log("Resolver deployed at", resolver.address);
}

main();

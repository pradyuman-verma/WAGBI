import { ethers } from "hardhat";

async function main() {
  const [signer] = await ethers.getSigners();
  // goerli
  const aaveV2LendingPool = "0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210";
  const aaveV2FallbackOracle = "0x0F9d5ED72f6691E47abe2f79B890C3C33e924092";
  const wethAddr = "0xCCa7d1416518D095E729904aAeA087dBA749A4dC";
  const usdcAddr = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074";
  const daiAddr = "0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33";
  const wbtcAddr = "0xf4423F4152966eBb106261740da907662A3569C5";
  const ENTRY = "0x2DF1592238420ecFe7f2431360e224707e77fA0E";
  const aaveDataProvider = "0x927F584d4321C1dCcBf5e2902368124b02419a1E";

  // mumbai
  // const aaveV2LendingPool = "0x9198F13B08E299d85E096929fA9781A1E3d5d827";
  // const aaveV2FallbackOracle = "0xC365C653f7229894F93994CD0b30947Ab69Ff1D5";
  // const wethAddr = "0x3C68CE8504087f89c640D02d133646d98e64ddd9";
  // const usdcAddr = "0x2058A9D7613eEE744279e3856Ef0eAda5FCbaA7e";
  // const daiAddr = "0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F";
  // const wbtcAddr = "0x0d787a4a1548f673ed375445535a6c7A1EE56180";
  // const ENTRY = "0x2DF1592238420ecFe7f2431360e224707e77fA0E";
  // const aaveDataProvider = "0xFA3bD19110d986c5e5E9DD5F69362d05035D045B";

  // const aaveV2LendingPool = "0x8dFf5E27EA6b7AC08EbFdf9eB090F32ee9a30fcf";
  // const aaveV2FallbackOracle = "0x0229F777B0fAb107F9591a41d5F02E4e98dB6f2d";
  // const wethAddr = "0x1E66e48DCA96eDc2BEB980a0CC3bd1c578BDf1cF";
  // const usdcAddr = "0x037A6B736a6a3Da9fe78b750cDac96681255Bccf";
  // const daiAddr = "0xaa34a2eE8Be136f0eeD223C9Ec8D4F2d0BC472dd";
  // const wbtcAddr = "0xD9a2E0c2755c72963d86D1F3A5130907F860Ca9b";
  // const ENTRY = "0x2DF1592238420ecFe7f2431360e224707e77fA0E";
  // const aaveDataProvider = "0x7551b5D2763519d4e37e8B81929D336De671d46d";

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
  console.log(await resolver.getUCUserData('0x86b96242f84FF0Cb3f1A85E265Ee6cD0473ff5d9'));
}

main();

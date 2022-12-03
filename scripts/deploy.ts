import { ethers } from "hardhat";

async function main() {
  const [signer] = await ethers.getSigners();
  const aaveV2FallbackOracle = "0x0F9d5ED72f6691E47abe2f79B890C3C33e924092";
  const wethAddr = "0xCCa7d1416518D095E729904aAeA087dBA749A4dC";
  const usdcAddr = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074";
  const daiAddr = "0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33";
  const wbtcAddr = "0xf4423F4152966eBb106261740da907662A3569C5";

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

  const Poola = await ethers.getContractFactory("LiquidityPoolImplementation");
  const poola = await Poola.deploy(
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr,
    oc.address,
    aaveV2FallbackOracle
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
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

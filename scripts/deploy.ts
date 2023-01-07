import { ethers } from "hardhat";
import { SignerWithAddress } from "hardhat-deploy-ethers/signers";
import { liquidityPool } from "../typechain/contracts";
import { Contract } from "ethers";

async function main() {
  const [deployer] = await ethers.getSigners();

  let token;
  // tokens
  token = await ethers.getContractFactory("TestToken");
  const weth = await token.deploy("Test WETH", "WETH", "18", {gasLimit: 40000000});
  await weth.deployed();
  console.log("WETH test token deployed at:", weth.address);

  token = await ethers.getContractFactory("TestToken");
  const usdc = await token.deploy("Test USDC", "USDC", "18");
  await usdc.deployed();
  console.log("USDC test token deployed at:", usdc.address);

  token = await ethers.getContractFactory("TestToken");
  const dai = await token.deploy("Test DAI", "DAI", "18");
  await dai.deployed();
  console.log("DAI test token deployed at:", dai.address);

  token = await ethers.getContractFactory("TestToken");
  const wbtc = await token.deploy("Test WBTC", "WBTC", "18");
  await wbtc.deployed();
  console.log("WBTC test token deployed at:", wbtc.address);

  const wethAddr = weth.address;
  const usdcAddr = usdc.address;
  const daiAddr = dai.address;
  const wbtcAddr = weth.address;

  const fakeContract = wethAddr;

  const wethAmount = ethers.utils.parseUnits("10000", "18");
  const usdcAmount = ethers.utils.parseUnits("1000000", "6");
  const daiAmount = ethers.utils.parseUnits("1000000", "18");
  const wbtcAmount = ethers.utils.parseUnits("100", "8");

  let proxyAdmin: Contract,
    liquidityPool: Contract,
    oracle: Contract,
    oc: Contract;

  let liquidityPoolImplementation: Contract,
    oracleImplementation: Contract,
    ocImplementation: Contract;

  let faucet: Contract, uiDataProvider: Contract;

  // proxies
  const ProxyAdmin = await ethers.getContractFactory("OrbitProxyAdmin");
  proxyAdmin = await ProxyAdmin.deploy(deployer.address);
  await proxyAdmin.deployed();
  console.log("Proxy Admin deployed at:", proxyAdmin.address);

  const Oracle = await ethers.getContractFactory("Oracle");
  oracle = await Oracle.deploy(fakeContract, proxyAdmin.address, "0x");
  await oracle.deployed();
  console.log("Oracle deployed at:", oracle.address);

  const LiquidityPool = await ethers.getContractFactory("LiquidityPool");
  liquidityPool = await LiquidityPool.deploy(
    fakeContract,
    proxyAdmin.address,
    "0x"
  );
  await liquidityPool.deployed();
  console.log("Liquidity Pool deployed at:", liquidityPool.address);

  const OC = await ethers.getContractFactory("OC");
  oc = await OC.deploy(fakeContract, proxyAdmin.address, "0x");
  await oc.deployed();
  console.log("OC deployed at:", oc.address);

  // faucet
  const Faucet = await ethers.getContractFactory("Faucet");
  faucet = await Faucet.deploy();
  await faucet.deployed();
  console.log("Faucet deployed at:", faucet.address);

  // implementations and setup
  const OracleImplementation = await ethers.getContractFactory(
    "OracleImplementation"
  );
  oracleImplementation = await OracleImplementation.deploy();
  await oracleImplementation.deployed();
  console.log(
    "Oracle implementation deployed at:",
    oracleImplementation.address
  );

  await proxyAdmin.upgrade(oracle.address, oracleImplementation.address);
  console.log("Oracle implementation upgraded!");

  const OracleProxy = await ethers.getContractAt(
    "OracleImplementation",
    oracleImplementation.address
  );
  await OracleProxy.setPrice(wethAddr, ethers.utils.parseEther("1"));
  console.log("WETH price set!");
  await OracleProxy.setPrice(usdcAddr, ethers.utils.parseEther("0.00083"));
  console.log("USDC price set!");
  await OracleProxy.setPrice(daiAddr, ethers.utils.parseEther("0.00083"));
  console.log("DAI price set!");
  await OracleProxy.setPrice(wbtcAddr, ethers.utils.parseEther("13"));
  console.log("WBTC price set!");

  const LiquidityPoolImplementation = await ethers.getContractFactory(
    "LiquidityPoolImplementation"
  );
  liquidityPoolImplementation = await LiquidityPoolImplementation.deploy(
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr,
    oc.address,
    fakeContract
  );
  await liquidityPoolImplementation.deployed();
  console.log(
    "Liquidity Pool implementation deployed at:",
    liquidityPoolImplementation.address
  );

  await proxyAdmin.upgrade(
    liquidityPool.address,
    liquidityPoolImplementation.address
  );
  console.log("Liquidity Pool implementation upgraded!");

  const liquidityPoolProxy = await ethers.getContractAt(
    "LiquidityPoolImplementation",
    liquidityPool.address
  );
  await liquidityPoolProxy.initialize(deployer.address);
  console.log("Liquidity Pool initialized!");

  await liquidityPoolProxy.updateProtocolParams(
    oc.address,
    [wethAddr, usdcAddr, daiAddr, wbtcAddr],
    [1, 1, 1, 1],
    [wethAddr, usdcAddr, daiAddr, wbtcAddr],
    [wethAmount, usdcAmount, daiAmount, wbtcAmount]
  );
  console.log("OC params set!");

  const OCImplementation = await ethers.getContractFactory("OCImplementation");
  ocImplementation = await OCImplementation.deploy(
    liquidityPool.address,
    oracle.address,
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr
  );
  await ocImplementation.deployed();
  console.log("OC implementation deployed at:", ocImplementation.address);

  await proxyAdmin.upgrade(oc.address, ocImplementation.address);
  console.log("OC implementation upgraded!");

  const ocProxy = await ethers.getContractAt("OCImplementation", oc.address);
  await ocProxy.initialize();
  console.log("OC initialized!");

  const UIDataProvider = await ethers.getContractFactory("UIDataProvider");
  uiDataProvider = await UIDataProvider.deploy(
    liquidityPool.address,
    oc.address,
    oracle.address,
    wethAddr,
    usdcAddr,
    daiAddr,
    wbtcAddr
  );
  await uiDataProvider.deployed();
  console.log("UI data provider deployed at:", uiDataProvider.address);
}

main();

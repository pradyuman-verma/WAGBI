import { Contract } from "ethers";
import { ethers } from "hardhat";
import { liquidityPool } from "../typechain/contracts";
const { expect } = require("chai");

describe("General", function () {
  const aaveV2LendingPool = "0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210";
  const aaveV2FallbackOracle = "0x0F9d5ED72f6691E47abe2f79B890C3C33e924092";
  const aaveV2DataProvider = "0x927F584d4321C1dCcBf5e2902368124b02419a1E";
  const wethAddr = "0xCCa7d1416518D095E729904aAeA087dBA749A4dC";
  const usdcAddr = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074";
  const daiAddr = "0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33";
  const wbtcAddr = "0xf4423F4152966eBb106261740da907662A3569C5";

  const fakeContract = aaveV2LendingPool;

  let deployer,
    proxyAdmin: Contract,
    liquidityPool: Contract,
    oracle: Contract,
    oc: Contract,
    ucFactory: Contract,
    nftManager: Contract,
    ucWallet: Contract;
  before(async () => {
    [deployer] = await ethers.getSigners();

    // proxies
    const ProxyAdmin = await ethers.getContractFactory("OrbitProxyAdmin");
    proxyAdmin = await ProxyAdmin.deploy(deployer.address);
    await proxyAdmin.deployed();
    console.log("Proxy Admin deployed at:", proxyAdmin.address);

    const LiquidityPool = await ethers.getContractFactory("LiquidityPool");
    liquidityPool = await LiquidityPool.deploy(
      fakeContract,
      proxyAdmin.address,
      "0x"
    );
    await liquidityPool.deployed();
    console.log("Liquidity Pool deployed at:", liquidityPool.address);

    const Oracle = await ethers.getContractFactory("Oracle");
    oracle = await Oracle.deploy(fakeContract, proxyAdmin.address, "0x");
    await oracle.deployed();
    console.log("Oracle deployed at:", oracle.address);

    const OC = await ethers.getContractFactory("OC");
    oc = await OC.deploy(fakeContract, proxyAdmin.address, "0x");
    await oc.deployed();
    console.log("OC deployed at:", oc.address);

    const UCFactory = await ethers.getContractFactory("UCWalletFactory");
    ucFactory = await UCFactory.deploy(fakeContract, proxyAdmin.address, "0x");
    await ucFactory.deployed();
    console.log("UC Factory deployed at:", ucFactory.address);

    const NftManager = await ethers.getContractFactory("NftManager");
    nftManager = await NftManager.deploy(
      fakeContract,
      proxyAdmin.address,
      "0x"
    );
    await nftManager.deployed();
    console.log("Nft Manager deployed at:", nftManager.address);

    const UCWallet = await ethers.getContractFactory("UCWallet");
    ucWallet = await UCWallet.deploy(fakeContract, proxyAdmin.address, "0x");
    await ucWallet.deployed();
    console.log("UC wallet deployed at:", ucWallet.address);

    // implementations
  });

  it("should deploy", async () => {
    expect(!!proxyAdmin.address).to.equal(true);
    expect(!!liquidityPool.address).to.equal(true);
    expect(!!oracle.address).to.equal(true);
    expect(!!oc.address).to.equal(true);
    expect(!!ucFactory.address).to.equal(true);
    expect(!!nftManager.address).to.equal(true);
    expect(!!ucWallet.address).to.equal(true);
  });
});

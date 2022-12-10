import { Contract } from "ethers";
import { ethers } from "hardhat";
const { expect } = require("chai");

describe("General", function () {
  const aaveV2LendingPool = "0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210";
  const aaveV2FallbackOracle = "0x0F9d5ED72f6691E47abe2f79B890C3C33e924092";
  const aaveV2DataProvider = "0x927F584d4321C1dCcBf5e2902368124b02419a1E";
  const wethAddr = "0xCCa7d1416518D095E729904aAeA087dBA749A4dC";
  const usdcAddr = "0x9FD21bE27A2B059a288229361E2fA632D8D2d074";
  const daiAddr = "0x75Ab5AB1Eef154C0352Fc31D2428Cef80C7F8B33";
  const wbtcAddr = "0xf4423F4152966eBb106261740da907662A3569C5";

  let deployer, proxyAdmin: Contract;
  before(async () => {
    [deployer] = await ethers.getSigners();

    const ProxyAdmin = await ethers.getContractFactory("OrbitProxyAdmin");
    proxyAdmin = await ProxyAdmin.deploy(deployer.address);
    await proxyAdmin.deployed();
    console.log("Proxy Admin deployed at:", proxyAdmin.address);
  });

  it("should contracts deployed", async () => {
    expect(!!proxyAdmin.address).to.equal(true);
  });
});

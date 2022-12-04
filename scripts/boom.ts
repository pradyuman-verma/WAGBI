import { wrapProvider } from "@account-abstraction/sdk";
import { ethers } from "ethers";
import { UCWalletFactory__factory, WagbiWallet__factory } from "../typechain";
const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545/");
const signer = provider.getSigner();

const ENTRY_POINT = "0x2DF1592238420ecFe7f2431360e224707e77fA0E";
const FACTORY_ADDR = "0x701F8f09FD8Ab9c585afFC269726a53Ad57aE61B";

const create = async () => {
  const Factory = new ethers.Contract(
    FACTORY_ADDR,
    UCWalletFactory__factory.abi,
    provider
  );

  const addr = await signer.getAddress();
  const tx = await Factory.connect(signer).callStatic.create(addr);
  console.log("🚀 ~ file: boom.ts:19 ~ create ~ tx", tx);

  //   let walletAddress = await Factory.connect(signer).authToWallet(addr, 0);
  //   console.log("🚀 ~ file: boom.ts:21 ~ create ~ walletAddress", walletAddress);

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

create();

const supply = async (token: string, amount: string) => {
  const config = {
    chainId: await provider.getNetwork().then((net) => net.chainId),
    entryPointAddress: ENTRY_POINT,
    bundlerUrl: "http://localhost:3000/rpc",
  };

  const Factory = new ethers.Contract(
    FACTORY_ADDR,
    UCWalletFactory__factory.abi,
    provider
  );
  const aaProvider = await wrapProvider(provider, config, signer);
  let walletAddress = await Factory.authToWallet(signer._address);

  const wagbiWallet = new ethers.Contract(
    walletAddress[walletAddress.length - 1],
    WagbiWallet__factory.abi,
    aaProvider
  );
  await wagbiWallet.supplyToWallet(token, amount);
};

const supplyToPool = async (token: string, amount: string) => {
  const config = {
    chainId: await provider.getNetwork().then((net) => net.chainId),
    entryPointAddress: ENTRY_POINT,
    bundlerUrl: "http://localhost:3000/rpc",
  };

  const Factory = new ethers.Contract(
    FACTORY_ADDR,
    UCWalletFactory__factory.abi,
    provider
  );
  const aaProvider = await wrapProvider(provider, config, signer);
  let walletAddress = await Factory.authToWallet(signer._address);

  const wagbiWallet = new ethers.Contract(
    walletAddress[walletAddress.length - 1],
    WagbiWallet__factory.abi,
    aaProvider
  );
  await wagbiWallet.supplyToLiquidityPool(token, amount, true);
};

const withdrawFromPool = async (token: string, amount: string) => {
  const config = {
    chainId: await provider.getNetwork().then((net) => net.chainId),
    entryPointAddress: ENTRY_POINT,
    bundlerUrl: "http://localhost:3000/rpc",
  };

  const Factory = new ethers.Contract(
    FACTORY_ADDR,
    UCWalletFactory__factory.abi,
    provider
  );
  const aaProvider = await wrapProvider(provider, config, signer);
  let walletAddress = await Factory.authToWallet(signer._address);

  const wagbiWallet = new ethers.Contract(
    walletAddress[walletAddress.length - 1],
    WagbiWallet__factory.abi,
    aaProvider
  );
  await wagbiWallet.withdrawFromLiquidityPool(
    token,
    amount,
    wagbiWallet.address
  );
};

const borrow = async (token: string, amount: string) => {
  const config = {
    chainId: await provider.getNetwork().then((net) => net.chainId),
    entryPointAddress: ENTRY_POINT,
    bundlerUrl: "http://localhost:3000/rpc",
  };

  const Factory = new ethers.Contract(
    FACTORY_ADDR,
    UCWalletFactory__factory.abi,
    provider
  );
  const aaProvider = await wrapProvider(provider, config, signer);
  let walletAddress = await Factory.authToWallet(signer._address);

  const wagbiWallet = new ethers.Contract(
    walletAddress[walletAddress.length - 1],
    WagbiWallet__factory.abi,
    aaProvider
  );
  await wagbiWallet.borrowToWallet(token, amount);
};

const payback = async (token: string, amount: string) => {
  const config = {
    chainId: await provider.getNetwork().then((net) => net.chainId),
    entryPointAddress: ENTRY_POINT,
    bundlerUrl: "http://localhost:3000/rpc",
  };

  const Factory = new ethers.Contract(
    FACTORY_ADDR,
    UCWalletFactory__factory.abi,
    provider
  );
  const aaProvider = await wrapProvider(provider, config, signer);
  let walletAddress = await Factory.authToWallet(signer._address);

  const wagbiWallet = new ethers.Contract(
    walletAddress[walletAddress.length - 1],
    WagbiWallet__factory.abi,
    aaProvider
  );
  await wagbiWallet.payback(token, amount, true);
};

const { ethers } = require("ethers");
const contractABI = [
  {
    inputs: [],
    name: "set",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "get",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
    constant: true,
  },
];

const contractAddress = "0x1FE9cb123Dcea7E2FE05a3e1380a9a232309e381";

const bekle = (ms) => new Promise((resolve) => setTimeout(resolve, ms));


async function get() {
  const provider = new ethers.providers.JsonRpcProvider("http://213.199.37.52:8545
");

  const private = "25B6AE2B8355701A400B358B08D5D70573BC3A8282F0F819A5C1322418FA5C34";

  //for sending from account 0

  let senderAccount = new ethers.Wallet(private);
  let walletsigner = await senderAccount.connect(provider);
  const contract = new ethers.Contract(
    contractAddress,
    contractABI,
    walletsigner
  );
  
  console.log(`${senderAccount.address} is ready. Please wait`);
  let bnonce = 0;
  while (true) {
    const delay = Math.floor(Math.random() * (3000 - 1000 + 1)) + 3000;
    const nonce = await provider.getTransactionCount(senderAccount.address);
    console.log(`**************Önceki nonce: ${bnonce} şu an ${nonce} beklenilen sure ${delay}`);
    let gasPrice = await provider.getGasPrice();
    console.log(`gas: ${gasPrice}`);
    try {
      const transaction = await contract.set({
        from: walletsigner.account,
      });

      await transaction.wait();

      console.log(`Transaction completed: ${transaction}`);
      bnonce = nonce;
      let storedData = await contract.get();
      console.log(`Stored Data: ${storedData}`);
    } catch (error) {
      console.log(`HATA: ${error}`);
    }

 

await bekle(delay);
  }
  }

get();

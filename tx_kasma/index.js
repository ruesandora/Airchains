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

const contractAddress = "KONTRAT ADRESİ";

const bekle = (ms) => new Promise((resolve) => setTimeout(resolve, ms));


async function get() {
  const provider = new ethers.providers.JsonRpcProvider("RPC");

  const private = "PRIVATE KEY";

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
    const delay = Math.floor(Math.random() * (5000 - 10000 + 1)) + 2000;
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

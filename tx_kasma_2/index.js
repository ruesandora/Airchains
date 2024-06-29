const ethers = require('ethers');
require('dotenv').config();
const {
    ADDRESS_RECEIVER,
    GAS_LIMIT,
    PRIVATE_KEY,
    ETH_RPC_URL
} = process.env;

const provider = new ethers.providers.JsonRpcProvider(ETH_RPC_URL);

const increaseGasBy = 15000000000;

async function getCurrentGasPrice() {
    try {
        const currentGasPrice = await provider.getGasPrice();
        return (Number(currentGasPrice) + increaseGasBy) + '';
    } catch (err) {
        console.error(err);
    }
}

const bot = async () => {
    provider.on("block", async () => {
        console.log("  Yeni Tx Oluşturuluyor...");
        const _target = new ethers.Wallet(PRIVATE_KEY);
        const target = _target.connect(provider);
        const balance = await provider.getBalance(target.address);
        const currentGasPrice = await getCurrentGasPrice();
        const balanceinEther = ethers.utils.formatEther(balance);
        
        if (Number(balanceinEther) > 0 && Number(currentGasPrice) > 0) {
            try {
                const randomDelay = Math.floor(Math.random() * 3000); // 0 ile 3000 ms arasında rastgele bir sayı
                await new Promise(resolve => setTimeout(resolve, randomDelay)); // Rastgele bekleme süresi
                const randomWei = Math.floor(Math.random() * 3) + 1; // 1 ile 3 arasında rastgele bir sayı
                await target.sendTransaction({
                    to: ADDRESS_RECEIVER,
                    value: ethers.utils.parseUnits(randomWei.toString(), "wei"), // Rastgele miktar
                    gasPrice: currentGasPrice.toString(),
                    gasLimit: GAS_LIMIT.toString()
                });
                console.log(`  Transfer Başarılı --> Cüzdan bakiyesi: ${ethers.utils.formatEther(await provider.getBalance(target.address))}`);
            } catch (error) {
                console.log(`  HATA, TEKRAR DENENİYOR...`);
            }
        }
    });
};

bot();

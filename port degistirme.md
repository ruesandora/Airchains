<h1>Port Değiştirme İşlemi</h1>
Sunucumuza girelim.

```
systemctl stop rolld

nano ~/.evmosd/config/app.toml
```
Aşağıdaki resimde 8545 ve 8546 portlarına herhangi bir sayı verebilirsiniz. Ben 8547 ve 8548 yaptım.

![image](https://github.com/ruesandora/Airchains/assets/101149671/588a02d0-f7e3-4c25-ac25-ffff281206eb)

Ctrl+x y enter yapıp çıkıyoruz. Daha sonra restart atıp logları kontrol edelim.

```
sudo systemctl restart rolld

sudo journalctl -u rolld -f --no-hostname -o cat
```
![image](https://github.com/ruesandora/Airchains/assets/101149671/64137490-6b3b-4678-ae26-81c90dd1f952)

Ayrıca bu iki portu açalım. Aşağıdaki portlar sizin kullandığınız porta göre farklı olabilir kendinize göre düzenleyebilirsiniz.
```
sudo ufw allow 8547
sudo ufw allow 8548
```
Portumuzu değiştirdik ek olarak metamasktan ve tx botundan rpc kısmını yenisine göre düzenlemeliyiz.



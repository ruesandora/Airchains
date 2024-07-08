>Öncelikle bir cüzdan adresine ihtiyacımız var. Cüzdan adresini .env yi düzenlerken kullanacağız
<h1 align="center">Node.js ve npm kurulumu </h1>

> Npm ve node.js kurulumunu yapalım

```
# komutları sırasıyla girelim:
screen -S send

curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
sudo bash /tmp/nodesource_setup.sh
sudo apt install nodejs

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install v20.10.0
nvm use v20.10.0
npm install -g npm@latest

```


> Daha sonra burada yeni bir klasör oluştur. npm ile proje oluştur. hepsini enter ile geçebilirsin.

```
mkdir send
cd send
npm init

```

> index.js dosyasını oluştur.  [Bu repodaki](https://github.com/ruesandora/Airchains/blob/main/tx_kasma_2/index.js) index.js değişiklik yapmadan yapıştır.

```

nano index.js

```
> .env dosyasını oluştur.  [Bu repodaki](https://github.com/ruesandora/Airchains/blob/main/tx_kasma_2/.env) buradaki bilgileri kendine göre düzenle.

```

nano .env

```

> Aynısını [package.json](https://github.com/ruesandora/Airchains/blob/main/tx_kasma_2/package.json) için yap

```

nano package.json

```

> En son aşağıdakileri çalıştıralım

```
npm install
node index.js

```

> Sıkıntı çıkmazsa Transefer Başarılı!! -->CÜZDAN BAKİYESİ

> 2  cüzdandan ana cüzdana transfer işlemi

```
screen -ls
screen -X -S <index.js nin çalıştığı screen kodu> quit

```

Metamask üzerinden 2, 3, 4 cüzdanlara tEVMOS gönderin.

```
nano .env

```
> bu repodaki güncel .env dosyasını kendinize göre düzenleyin. ctrl x+y Enter. Aynı işlemleri index2.js index3.js index4.js için aşağıdaki kodları tekrar ederek yapın.

```
nano index2.js
screen -S tx
node index.js
ctrl a+d
screen -S tx2
node index2.js
ctrl a+d

```

> Burada eğer 3 ve 4. tx atmayı da yapacaksanız PKEY3 ve PKEY4 değerlerini .env dosyasına girip, index3.js içinde PKEY2 yazan yeri PKEY3, index4.js içinde PKEY4 yazmalısınız.
> BU şekilde dakikada 1 pod, saatte 60 pod ve günde yaklaşık 1400 pod'a kadar işlem yapılabiliyor.

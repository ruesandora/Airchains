<h1 align="center">Node.js ve npm kurulumu yapma</h1>

> Npm ve node.js kurulumunu yapalım

```
# komutları sırasıyla girelim:
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

> index.js dosyasını oluştur.  [Bu repodaki](https://github.com/ErsanAydin/Airchains/blob/main/tx_kasma_2/index.js) index.js değişiklik yapmadan yapıştır.

```

nano index.js

```
> .env dosyasını oluştur.  [Bu repodaki](https://github.com/ErsanAydin/Airchains/blob/main/tx_kasma_2/.env) buradaki bilgileri kendine göre düzenle.

```

nano .env

```

> Aynısını [package.json](https://github.com/ErsanAydin/Airchains/blob/main/tx_kasma_2/package.json) için yap

```

nano package.json

```

> En son aşağıdakileri çalıştıralım

```
npm install
node index.js

```

> Sıkıntı çıkmazsa Transefer Başarılı!! -->CÜZDAN BAKİYESİ

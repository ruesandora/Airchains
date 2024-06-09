<h1 align="center">Contract Deployment</h1>

> UYARI : [Remix](https://remix.ethereum.org/) üzerinden bir dosya oluştur. Aşağıdaki kodu ekle.
> İlk önce compile et sonra Metamask kullanarak deploy et
> Aşağıdaki bölümden kontrat adresini not et.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SimpleStorage {
    uint storedData;

    function set() public {
        storedData = storedData + 1;
    }

    function get() public view returns (uint) {
        return storedData;
    }
}
```

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
mkdir bot
cd bot
npm init

```

> index.js dosyasını oluştur. Bu repodaki index.js klasorunu düzelterek yapıştır.

```

nano index.js

```

> Aynısını package.json için yap

```

nano package.json

```

> En son aşağıdakileri çalıştıralım

```
npm install
node index.js

```

> Herşey doğru ise Stored Data sürekli aratacak.

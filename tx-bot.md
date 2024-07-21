> Npm ve node.js kurulumunu yapalım

```console
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

```console
git clone https://github.com/AkifhanIlgaz/airchains-tx-bot.git
cd airchains-tx-bot
npm install
nano index.js
```

> IP ve PRIV_KEY yazan yerleri değiştirelim. İsterseniz işlem aralığını değiştirebilirsiniz.

> CTRL + X + Y + Enter ile çıkalım

> Screen oluşturup botu başlatalım.
```console
screen -S airchain
node index.js
```

> Ctrl + A + D ile screenden çıkabilirsiniz.

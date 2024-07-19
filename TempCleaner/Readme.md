<h1 align="center">Gereksiz Temp Temizleme</h1>


> UYARI : Bunu kullanmak herkesin kendi mesuliyetindedir.

Bu yöntem ile tx botlarının oluşturduğu gereksiz temp dosyalarını silerek depolamamızda yer açıyoruz. Kodu çalıştırdığınızda ve bunu takip eden her 12 saatte kullanılmayan temp dosyaları siliniyor.

> 80gb dolmuş sunucuda denediğimde 64gb gereksiz dosya silindi. 

<h2 align="center">Kurulum</h2>

> Sunucuzda npm ve node.js kurulu ise bu kısmı geçebilirsiniz.

Npm ve node.js kurulumu 

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
Screen Açalım

> Screen indirelim.

```console
apt install screen
```

> Screen oluşturalım.

```console
screen -S tempcleaner
```

> Sonra yeni bir klasör oluşturalım. Ardından npm ile proje oluşturalım. Hepsini enter ile geçebilirsiniz.

```console
cd $HOME
mkdir tempcleaner
cd tempcleaner
npm init
```

> tempCleaner.js dosyasını oluşturun. Bu repodaki index.js değiştirmeden yapıştırın. Ctrl+X Y sonra Enter ile kaydedin. 

```console
nano tempCleaner.js
```

> package.json dosyasını oluşturun. Ctrl+K ile hepsini sil. Githubdan package.json kopyala yapıştır. Ctrl+X Y sonra Enter ile kaydedin.

```console
nano package.json
```

> En son aşağıdakileri çalıştıralım

```console
npm install
node tempCleaner.js
```

 Ctrl+A+D ile çıkabilirsiniz.
> Screen içine girmek için;

```console
screen -r tempcleaner
```

Depolama kontrol kodu

```console
df -h
```
> Bu kod ile kullanılan ve boş depolama miktarınızı görebilirsiniz.

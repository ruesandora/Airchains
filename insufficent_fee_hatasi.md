Yeni sürümdeki gas hatası sebebiyle yetersiz fee hatası alınabiliyor. 
Güncelleme gelene kadar bunu uygulayabilirsiniz.

![image](https://github.com/neuweltgeld/Airchains_/assets/101174090/c4651e1c-ee88-4a65-8a01-bffaf56035a0)

# cüzdanda yeteri kadar amf token olduğuna emin olun
# trackeri durdurun

systemctl stop stationd

# submitPod.go dosyasına girin
nano ~/tracks/junction/submitPod.go

# şu kodu bulup 

gas := utilis.GenerateRandomWithFavour(100, 300, [2]int{120, 250}, 0.7)

# aşağıdakiyle değiştirin

gas := utilis.GenerateRandomWithFavour(510, 1000, [2]int{520, 700}, 0.7)

# ctrl + x ve y ile kaydedip çıkın.

# tracks klasörüne girin değişiklikleri uygulayın

cd $HOME/tracks

go mod tidy

# trackeri yeniden başlatın

systemctl restart stationd && sudo journalctl -u stationd -f --no-hostname -o cat

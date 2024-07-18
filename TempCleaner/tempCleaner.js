const cron = require('node-cron');
const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readdir = promisify(fs.readdir);
const stat = promisify(fs.stat);
const unlink = promisify(fs.unlink);

const TEMP_DIR = '/tmp';
const DAYS_UNUSED = 7;
const MILLISECONDS_IN_A_DAY = 24 * 60 * 60 * 1000;

async function cleanOldTempFiles() {
  try {
    const files = await readdir(TEMP_DIR);
    const now = Date.now();

    for (const file of files) {
      const filePath = path.join(TEMP_DIR, file);
      const fileStat = await stat(filePath);

      // Son erişim tarihini kontrol et
      const lastAccessTime = new Date(fileStat.atime).getTime();
      const fileAge = (now - lastAccessTime) / MILLISECONDS_IN_A_DAY;

      if (fileAge > DAYS_UNUSED) {
        await unlink(filePath);
        console.log(`Silindi: ${filePath}`);
      }
    }
  } catch (error) {
    console.error(`Hata oluştu: ${error.message}`);
  }
}

// Kod çalıştırıldığında temizlik yap
console.log('Kullanılmayan temp dosyaları temizleniyor...');
cleanOldTempFiles().then(() => {
  console.log('İlk temp dosya temizleme işlemi tamamlandı.');
});

// Her 12 saatte bir çalışacak cron job tanımlaması
cron.schedule('0 */12 * * *', () => {
  console.log('Kullanılmayan temp dosyaları temizleniyor...');
  cleanOldTempFiles().then(() => {
    console.log('Temp dosya temizleme işlemi tamamlandı.');
  });
});

console.log('Temp dosya temizleyici cron job başlatıldı.');
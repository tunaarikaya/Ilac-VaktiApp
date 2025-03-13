# İlaç Vakti

İlaç Vakti, kullanıcıların ilaç kullanım takibini kolaylaştıran, düzenli ilaç kullanımı için hatırlatmalar sunan ve ilaç kullanım alışkanlıklarını analiz eden kapsamlı bir iOS uygulamasıdır.

## Özellikler

- **Ana Sayfa**: 
  - Günlük ilaç programınızı görüntüleyin
  - İlaçlarınızı yönetin ve alımlarınızı kaydedin
  - Tarih seçip geçmiş veya gelecek ilaç programlarınıza bakın
  - Boş durum gösterimi ile kolay kullanım

- **Takvim**: 
  - Aylık ilaç kullanım programınızı görüntüleyin
  - Geçmiş ilaç kullanımlarınızı takip edin
  - Tarih seçerek o güne ait ilaç bilgilerine erişin
  - Kolay gezinme için ay değiştirme butonları

- **Eczane Haritası**: 
  - Size en yakın eczaneleri bulun
  - Gerçek zamanlı konum takibi ile çevredeki eczaneleri görüntüleyin
  - Eczanelerin detaylarını görün (adres, çalışma saatleri)
  - Haritada arama yaparak belirli eczaneleri bulun

- **İlaç Yönetimi**:
  - Yeni ilaç ekleyin ve detaylı bilgiler girin
  - İlaçlarınız için hatırlatma saatleri belirleyin
  - İlaç kullanım talimatlarını kaydedin
  - İlaç bilgilerinizi düzenleyin veya silin

- **Ayarlar**:
  - Uygulama görünümünü kişiselleştirin (karanlık mod desteği)
  - Bildirim ayarlarını yönetin
  - Uygulama hakkında bilgilere erişin
  - Gizlilik politikası ve yardım bölümlerine ulaşın

## Teknik Özellikler

- iOS 14.0+ desteği
- Karanlık mod desteği
- CoreData ile yerel veri saklama
- MapKit ve CoreLocation ile harita entegrasyonu
- OneSignal ile bildirim yönetimi
- Kullanıcı dostu arayüz tasarımı
- Animasyonlu geçişler ve etkileşimler

## Mimari

Uygulama, MVVM (Model-View-ViewModel) mimarisi kullanılarak geliştirilmiştir. Bu mimari, kod organizasyonunu iyileştirirken, test edilebilirliği ve bakımı kolaylaştırır.

### Proje Yapısı

```
ilaç Vakti/
├── Core/
│   ├── CoreDataManager.swift
│   ├── TabBarController.swift
│   └── Models/
│       └── MedicationModel.xcdatamodeld
├── Features/
│   ├── Home/
│   │   ├── View/
│   │   │   ├── HomeViewController.swift
│   │   │   ├── AddIlacViewController.swift
│   │   │   └── IlacDetayViewController.swift
│   │   ├── ViewModel/
│   │   └── Model/
│   ├── Calendar/
│   │   ├── View/
│   │   │   └── CalendarViewController.swift
│   │   ├── ViewModel/
│   │   └── Model/
│   ├── Map/
│   │   ├── View/
│   │   │   ├── MapViewController.swift
│   │   │   └── AddEczaneViewController.swift
│   │   ├── ViewModel/
│   │   └── Model/
│   └── Settings/
│       ├── View/
│       │   └── SettingsViewController.swift
│       ├── ViewModel/
│       └── Model/
└── Utils/
    ├── Extensions/
    └── Helpers/
```

## Gereksinimler

- iOS 14.0+
- Xcode 13.0+
- Swift 5.0+

## Kurulum

1. Projeyi klonlayın:
```bash
git clone https://github.com/kullaniciadi/ilac-vakti.git
```

2. Bağımlılıkları yükleyin (OneSignal):
```bash
pod install
```
veya
```bash
swift package update
```

3. Xcode ile projeyi açın:
```bash
open "ilaç Vakti.xcodeproj"
# veya .xcworkspace dosyasını açın (CocoaPods kullanıldıysa)
```

4. Uygulamayı bir simülatörde veya gerçek cihazda çalıştırın.

## Katkıda Bulunma

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inize push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakın. 
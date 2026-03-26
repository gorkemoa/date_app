
Bu proje, iş ve arkadaşlık odaklı, swipe/card mantığıyla çalışan, modern ve premium hissiyat veren bir Flutter demo uygulamasıdır.

Bu sürüm canlı backend içermeyen bir demo sürüm olacaktır. Ancak proje, ileride gerçek API entegre edilecekmiş gibi production düzenine yakın bir mimari ile kurulmalıdır.

---

## Projenin Temel Amacı

Bu projenin amacı şunlardır:

- güçlü ve özenli bir UI ortaya koymak
- tüm cihazlarda düzgün çalışan responsive yapı kurmak
- MVVM mimarisine tam uymak
- ileride gerçek API geldiğinde minimum kırılımla entegre edilebilir temel hazırlamak
- dağınık, widget içine gömülmüş, teknik borç üreten koddan kaçınmak

Bu proje demo bahanesiyle düzensiz yazılmayacaktır.  
Demo olsa da kurgu ciddi olacaktır.

---

## Zorunlu Teknolojiler

- Flutter
- Dart
- MVVM mimarisi
- Provider veya ChangeNotifier tabanlı state yönetimi
- Tüm proje yapısı yalnızca `lib/` altında organize edilecek

---

## Zorunlu Katmanlar

`lib/` altında mutlaka şu klasörler olacak:

- `core`
- `models`
- `views`
- `viewmodels`
- `services`

İhtiyaca göre bunların içinde alt klasörler açılabilir.  
Ama bu ana yapı korunmak zorundadır.

---

## Mimari Akış

Aşağıdaki akış zorunludur:

**View -> ViewModel -> Service -> Model/Response -> ViewModel -> View**

Bu akış bozulmayacaktır.

### Yasaklar
- View içinden doğrudan servis çağırmak
- Widget içinde business logic yazmak
- Widget içinde demo veri üretmek
- Widget içinde response parse etmek
- ViewModel atlayıp direkt veri kaynağına gitmek
- Service içinde UI kararı vermek
- UI katmanında veri kaynağı tasarlamak

---

## Demo Sürüm Mantığı

Bu proje canlı API kullanmayacaktır.  
Ancak veri akışı yine de gerçek API varmış gibi kurulmalıdır.

### Zorunlu kurgu
- `services` katmanında demo servisler olacak
- demo servisler response model döndürecek
- servisler doğrudan `List<Map<String, dynamic>>` döndürmeyecek
- veriler model üzerinden taşınacak
- response katmanı olacak
- loading, empty, error state senaryoları simüle edilebilecek

### Amaç
Canlıya geçiş sırasında view ve viewmodel çöpe gitmesin.  
Sadece demo service yerine gerçek API service takılarak devam edilebilsin.

---

## Response Yapısı Zorunluluğu

Demo veri bile response yapısı içinde döndürülmelidir.

Örnek mantık:

```dart
class BaseResponse<T> {
  final bool status;
  final String message;
  final T? data;
  final PaginationMeta? meta;
  final ApiError? error;

  BaseResponse({
    required this.status,
    required this.message,
    this.data,
    this.meta,
    this.error,
  });
}

Bu örnek birebir kullanılmak zorunda değildir.
Ancak mantık korunmalıdır.

Beklenen alanlar
status
message
data
meta
error

İleride API eklendiğinde sistem dağılmamalıdır.

Demo Veri Kullanım Kuralları
Kabul edilen
services/demo/ içinde tanımlı demo kaynaklar
model bazlı veri üretimi
response sarmalı ile dönüş
loading simülasyonu
error simülasyonu
empty state simülasyonu
Kesin yasak
widget içine gömülü veri
view içinde random sample data
business logic ile UI'nın iç içe geçmesi
veri kaynağının view tarafından yönetilmesi
response yapısı olmadan düz liste dönmek
Tasarım Kuralları

Bu proje için tasarım kalitesi çok önemlidir.
Tasarım sadece güzel değil, aynı zamanda sistemli olmalıdır.

Beklenen tasarım hissi
premium
modern
temiz
sosyal ama güven veren
sade ama sıradan olmayan
startup ürünü kalitesinde
Zorunlu ilkeler
tutarlı spacing sistemi
tutarlı radius sistemi
tutarlı tipografi hiyerarşisi
tutarlı shadow kullanımı
merkezi renk yönetimi
merkezi text style yönetimi
merkezi component davranışları
aynı ekosistem hissi veren ekranlar
Yasaklar
her widget içinde ayrı renk tanımlamak
rastgele padding kullanmak
rastgele border radius kullanmak
her ekranda farklı buton dili kullanmak
tek ekrana özen gösterip diğerlerini zayıf bırakmak
görsel kalitesi düşük bileşenler üretmek
Responsive Kuralları

Uygulama tüm cihazlarda çalışmalıdır.

Zorunlu cihaz senaryoları
küçük telefon
standart telefon
büyük telefon
tablet
Zorunlu durumlar
farklı yükseklikler
farklı genişlikler
taşan text senaryoları
uzun isim / uzun açıklama senaryoları
kısa veri / uzun veri senaryoları
Yasaklar
sabit width yüzünden bozulan yapı
ekrana sığmayan kartlar
overflow veren satırlar
sadece tek cihazda düzgün görünen layout
text büyüyünce dağılan component yapısı
Beklenen yaklaşım
esnek layout
kontrollü max width kullanımı
LayoutBuilder
MediaQuery
Expanded
Flexible
AspectRatio
gerektiğinde scroll destekli esnek yapı
Tema Sistemi

Tema ve ortak tasarım kararları merkezi olmalıdır.

Örnek yapı:

lib/core/theme/
  app_colors.dart
  app_text_styles.dart
  app_spacing.dart
  app_radius.dart
  app_shadows.dart
  app_theme.dart
Zorunluluklar
renkler merkezi olacak
spacing değerleri merkezi olacak
radius değerleri merkezi olacak
typography merkezi olacak
shadow kararları merkezi olacak
buton ve input stilleri ortak sistemle yönetilecek
Önerilen Klasör Yapısı
lib/
  core/
    components/
    config/
    constants/
    enums/
    extensions/
    routing/
    theme/
    utils/

  models/
    common/
    onboarding/
    user/
    profile/
    discover/
    match/

  services/
    base/
    demo/
    interfaces/

  viewmodels/
    base/
    onboarding/
    discover/
    matches/
    profile/
    home/

  views/
    shared/
    onboarding/
    discover/
    matches/
    profile/
    home/

Bu yapı korunmalıdır.

Katman Sorumlulukları
1. core

Ortak sistemler burada tutulur.

İçerebilecekleri
app constants
route yönetimi
tema sistemi
ortak widget'lar
helper'lar
extension'lar
enum'lar
config yapıları
Yasak
feature'a özel business logic
ekran verisi
feature state'i
2. models

Tüm veri modelleri burada tutulur.

Örnek modeller
BaseResponse
ApiError
PaginationMeta
UserModel
DiscoverCardModel
ProfileModel
MatchModel
InterestModel
OnboardingOptionModel
Zorunluluk

Model katmanı ciddi kurulmalıdır.
Demo diye gevşetilmeyecektir.

3. services

Servis katmanı veri kaynağını yönetir.

Zorunlu yapı
interface tabanlı kurgu tercih edilmeli
demo servisler ayrı tutulmalı
servisler model/response dönmeli
UI bilmemeli
BuildContext bilmemeli
Örnek
IDiscoverService
DemoDiscoverService
IProfileService
DemoProfileService
Yasak
service içinde widget import etmek
service içinde snack bar kararı vermek
service içinde navigation yapmak
4. viewmodels

Ekran state yönetimi burada olur.

Sorumluluklar
loading yönetimi
empty state yönetimi
hata yönetimi
servis çağrıları
veriyi view için hazırlamak
ekran aksiyonlarını yönetmek
Örnek
OnboardingViewModel
DiscoverViewModel
MatchesViewModel
ProfileViewModel
Yasak
widget üretmek
context bağımlı karmaşık UI kararı vermek
doğrudan veri kaynağına bağlanmak
service katmanını atlamak
5. views

UI burada çizilir.

Zorunlu prensip

View mümkün olduğunca dumb olmalıdır.

View ne yapar
viewmodel dinler
component tree çizer
user action'ları viewmodel'e iletir
tema sistemini kullanır
View ne yapmaz
veri üretmez
servis çağırmaz
response parse etmez
business rule yazmaz
State Yönetimi

Bu demo için basit ama temiz state yönetimi kullanılmalıdır.

Uygun seçenekler
Provider
ChangeNotifier
Beklenen base viewmodel özellikleri
isLoading
errorMessage
isInitialized
hasError
güvenli notify yapısı
dispose sonrası notify koruması

Async işlem sonrası dispose hataları oluşmamalıdır.

API'ye Hazır Kurgu

Bu proje bugün demo, yarın canlı olabilir.
Bu yüzden kurgunun baştan API-ready olması gerekir.

Beklenen yapı
servis interface'leri tanımlı olsun
demo service ile gerçek service yer değiştirebilir olsun
response modelleri bozulmasın
viewmodel aynı kalsın
mümkünse request modelleri de düşünülerek ilerlenebilsin
Amaç

Canlı backend geldiğinde proje baştan yazılmasın.

Veri Kaynağı Yaklaşımı

Demo veri, gerçek API şemasını taklit edecek şekilde tutulmalıdır.

Örnek senaryolar
discover kart listesi
kullanıcı profil detayı
önerilen eşleşmeler
onboarding seçenekleri
kullanıcı rozetleri
ilgi alanları
mesaj önizlemeleri

Bu veriler servis tarafından sağlanmalı, widget içine gömülmemelidir.

UI Component Sistemi

Ortak bileşen sistemi kurulmalıdır.

Beklenen ortak component örnekleri
primary button
secondary button
app text field
app search field
chip / tag
profile badge
swipe card
empty state view
loading view
error state view
section header
app scaffold wrapper

Bu bileşenler core/components veya views/shared/components altında anlamlı şekilde organize edilmelidir.

Ekran Önerileri

Demo sürüm için aşağıdaki ekranlar düşünülebilir:

Splash
Onboarding
Login / Continue Screen
Home
Discover
Discover Detail
Matches
Chat Preview
Profile
Edit Profile
Settings

Bu ekranlar tasarım dili açısından tek ekosistem gibi görünmelidir.

Kod Kalitesi Kuralları
Zorunlu
temiz dosya isimlendirmesi
anlamlı sınıf isimleri
uzun widget'ları bölmek
tekrar eden yapıları componentleştirmek
magic number kullanmamak
tema dışı rastgele tasarım değeri kullanmamak
okunabilir method isimleri kullanmak
Yasak
anlamsız kısaltmalar
tek dosyada devasa kod yığını
500 satırlık widget sınıfları
tasarım değerlerini ekrana gömmek
viewmodel içine alakasız her şeyi doldurmak
İsimlendirme Kuralları
Dosya isimleri
snake_case
Sınıf isimleri
PascalCase
Değişken ve method isimleri
camelCase
Örnek
discover_view.dart
discover_view_model.dart
demo_discover_service.dart
user_profile_model.dart
Null Safety ve Hata Toleransı

Kod null-safe yazılmalıdır.

Zorunlu
defensive parsing
boş veri ihtimaline dayanıklı viewmodel
fallback mantığı
loading / empty / error state ayrımı
Yasak
her şeyi non-null varsaymak
veri gelmediğinde UI'nın patlaması
response başarısız olduğunda ekranın çökmesi
Performans Prensipleri

Demo olsa da performans özensiz bırakılmayacaktır.

Beklenenler
gereksiz rebuild azaltılmalı
büyük widget'lar parçalanmalı
listeler optimize edilmeli
pahalı hesaplar build içinde yapılmamalı
sürekli yeniden hesaplanan style nesneleri azaltılmalı
Animasyon Prensipleri

Animasyon olabilir ancak kontrollü kullanılmalıdır.

Beklenen
akıcı
premium
kısa ve temiz
kart hissini güçlendiren geçişler
sayfalar arası tutarlı mikro etkileşimler
Yasak
dikkat dağıtan fazla hareket
yavaş ve hantal animasyonlar
görsel şov uğruna UX bozmak
Demo Amaçlı Ama Production Disiplinli

Bu proje demo olsa bile aşağıdaki bilinçle yazılmalıdır:

bugün statik veriyle çalışır
yarın gerçek API bağlanabilir
bugün görsel vitrin görevi görür
yarın ürüne dönüşebilir
bugün Copilot ile üretilecek
ama ortaya amatör kurgu çıkmayacak
Teslim Beklentisi

Projede beklenen çıktı:

temiz Flutter yapı
sağlam MVVM ayrımı
düzenli klasör yapısı
API entegrasyonuna hazır servis kurgusu
merkezi tema sistemi
responsive premium UI
kontrollü demo veri akışı
okunabilir ve sürdürülebilir kod
Son Not

Bu repo hızlıca bir şey göstermek için dağınık yazılmayacaktır.
Demo olması kalite standardını düşürmeyecek.
Tam tersine, ileride büyütülebilecek düzenli bir temel kurulacaktır.
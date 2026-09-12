# miscale2

Flutter aplikacija (Android + iOS) koja čita mjerenja s **Xiaomi Body Composition
Scale 2** i zapisuje ih u **Apple Health** odnosno **Android Health Connect**.

## Kako radi

Vaga se ne upari niti se na nju spaja — cijelo mjerenje emitira u BLE
advertisementu (Body Composition Service, UUID `0x181B`, 13 bajtova). Aplikacija
samo sluša okolinu dok je otvoren zaslon za vaganje, parsira paket i iz težine i
bio-impedancije izračuna sastav tijela.

Neke serije se javljaju pod nestandardnim servisom; njih se prepoznaje po imenu
(`MIBFS`, `MIBCS`, `MI_SCALE`, `BLESmart_…`, `XMTZC`) i čita po duljini paketa.
Kad vaga nije prepoznata, *Postavke → BLE dijagnostika* ispisuje sve
advertisemente u dometu sa sirovim bajtovima.

Podržan je i stariji Mi Scale v1 (`0x181D`, 10 bajtova), ali bez sastava tijela
jer ta vaga ne mjeri impedanciju.

### Tijek vaganja

1. Zaslon vaganja skenira sam od sebe dok je otvoren i aplikacija je u
   prvom planu — korisnik samo stane bos na vagu. Skeniranje prestaje čim
   se ode na drugu karticu ili u pozadinu.
2. Vaga šalje težinu u realnom vremenu, zatim paket s postavljenim bitom
   "stabilizirano".
3. Sekundu-dvije kasnije stiže paket s impedancijom. Ako izostane (npr. korisnik
   je u čarapama), nakon 8 sekundi sprema se samo težina.
4. Mjerenje se pripiše profilu prema rasponu težine; ako raspon odgovara za više
   profila ili nijedan, korisnik bira ručno.
5. Mjerenje se sprema lokalno i, ako je profil povezan s Healthom, odmah šalje
   dalje. Neuspjeli upisi ostaju u redu i šalju se preko *Postavke → Pošalji
   neposlana mjerenja*.

## Struktura

```
lib/
  core/ble/        parser BLE advertisementa i skener (flutter_blue_plus)
  core/body/       izračun sastava tijela
  core/health/     upis u HealthKit / Health Connect (health)
  data/db/         Drift (SQLite) baza profila i mjerenja
  data/repositories/  spaja očitanje, izračun, bazu i Health
  features/        zasloni: vaganje, povijest, profili, postavke
  providers.dart   Riverpod providers
```

## Što se zapisuje u Health

| Vrijednost           | Apple Health | Health Connect |
| -------------------- | ------------ | -------------- |
| Težina               | ✅            | ✅              |
| Postotak masti       | ✅            | ✅              |
| Nemasna masa         | ✅            | ✅              |
| BMI                  | ✅            | — (nema zapisa) |
| Masa vode            | — (nema zapisa) | ✅           |
| Bazalni metabolizam  | —¹           | ✅              |

¹ HealthKit "basal energy" je potrošnja kroz vrijeme, pa bi upis BMR-a kao
trenutačne vrijednosti iskrivio dnevni zbroj kalorija.

Ostale vrijednosti (voda u postotku, mišićna masa, kosti, proteini, visceralna
mast, metabolička dob) prikazuju se u aplikaciji i čuvaju u lokalnoj bazi.

## Pokretanje

```bash
flutter pub get
dart run build_runner build     # generira Drift kod nakon promjene tablica
flutter run
flutter test
```

### Android

- `minSdk 26` (zahtjev Health Connecta), `compileSdk 37` (zahtjev
  permission_handlera).
- Na uređaju mora biti instaliran Health Connect; aplikacija nudi instalaciju
  ako nedostaje.

### iOS

- HealthKit capability je uključen preko `ios/Runner/Runner.entitlements`. Za
  potpisivanje na stvarnom uređaju HealthKit mora biti omogućen i za App ID u
  Apple Developer portalu.
- Potrebne poruke o privatnosti (Bluetooth, Zdravlje) već su u `Info.plist`.

## Napomena o točnosti

Formule za sastav tijela reverzno su inženjerirane iz Mi Fit aplikacije
(projekti [openScale](https://github.com/oliexdev/openScale) i
[xiaomi_mi_scale](https://github.com/lolouk44/xiaomi_mi_scale)) jer Xiaomi
algoritam nije javno dokumentiran. Rezultati odgovaraju onima u Mi Fitu, ali su
procjena — nisu medicinski mjerni podatak.

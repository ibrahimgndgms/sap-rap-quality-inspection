# Quality Inspection Management System (SAP BTP ABAP Cloud & RAP)

![SAP BTP](https://img.shields.io/badge/SAP_BTP-ABAP_Cloud-008FD3?style=flat-square&logo=sap)
![RAP](https://img.shields.io/badge/Architecture-Managed_RAP-2B6CB0?style=flat-square)
![OData V4](https://img.shields.io/badge/Protocol-OData_V4-38A169?style=flat-square)
![Clean Core](https://img.shields.io/badge/Standard-Clean_Core-4A5568?style=flat-square)

**SAP BTP ABAP Environment (ABAP Cloud)** üzerinde **Managed RAP** mimarisi ve **Fiori Elements (OData V4)** kullanılarak geliştirilmiş uçtan uca Kalite Kontrol Yönetim uygulaması.

## Temel Özellikler

* **Composite Veri Modeli:** Üst başlık (`ZR_INSP_HEADER_06`) ve alt kusur kalemlerinden (`ZR_INSP_ITEMS_06`) oluşan **Draft** destekli yapı.
* **Otomatik Risk Skorlaması:** Alt kalemlerdeki kusur şiddetine (`Severity`) göre üst başlıktaki risk skorunu dinamik olarak hesaplayan `Determination`.
* **Parametreli Aksiyon (Popup):** `RejectBatch` aksiyonu ile **Abstract Entity** üzerinden zorunlu reddetme gerekçesi alan diyalog penceresi.
* **Dinamik UI & Yetki Kontrolü:** Kayıt statüsüne göre butonları kilitleyen `get_instance_features` ve özel yetkilendirme nesnesi (`ZAO_INSP06`) ile fabrika bazlı kontrol sağlayan `get_instance_authorizations`.
* **Veri Doğrulama & F4:** `Validations` kuralları ve Master Data tablolarına bağlı `@Consumption.valueHelpDefinition` tanımları.
* **Kalite ve Test Güvencesi:** `ABAP_CLOUD_DEVELOPMENT_DEFAULT` varyantında **0 Error** ATC Clean Core uyumluluğu ve `cl_cds_test_environment` ile izole **ABAP Unit** testleri.

## Ekran Görüntüleri

| List Report (Kritiklik & Filtreler) | Object Page (Detay & Kilitli Butonlar) |
| :---: | :---: |
| ![List Report]([docs/01_list_report.png](https://github.com/ibrahimgndgms/sap-rap-quality-inspection/blob/main/01_list_report.png) | ![Object Page]([docs/02_object_page_locked.png](https://github.com/ibrahimgndgms/sap-rap-quality-inspection/blob/main/02_object_page_locked.png)) |

| Parametreli Reddetme Popup'ı | İş Kuralı Doğrulama (Value Help) |
| :---: | :---: |
| ![Reject Popup]([docs/03_reject_popup.png](https://github.com/ibrahimgndgms/sap-rap-quality-inspection/blob/main/03_reject_popup.png) | ![Value Help]([docs/04_validation_f4.png](https://github.com/ibrahimgndgms/sap-rap-quality-inspection/blob/main/04_validation_f4.png)) |

ATC Clean Core Raporu |
| :---: |
| ![ATC](https://github.com/ibrahimgndgms/sap-rap-quality-inspection/blob/main/06_atc_clean_core.png) |

## Kurulum (abapGit)

1. Eclipse ADT üzerinden SAP BTP ABAP ortamına bağlanıp boş bir paket oluşturun (örn. `ZRAP_QUALITY_06`).
2. **abapGit Repositories** görünümünden bu repoyu (`refs/heads/main`) pakete bağlayıp **Pull** ile nesneleri aktifleştirin.
3. **`ZUI_INSP_O4_06`** Service Binding dosyasını açıp **Publish** butonuna basın ve **Preview** ile uygulamayı başlatın.

## Geliştirici

**İbrahim Gündoğmuş** — Computer Engineering | SAP ABAP & BTP Cloud Developer

CLASS zc_fill_valuhelp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zc_fill_valuhelp IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_plants  TYPE TABLE OF zinsp_plant,
          lt_defects TYPE TABLE OF zinsp_defect_t.

    " Tekrar çalıştırıldığında çakışma olmaması için önce tabloları temizle
    DELETE FROM zinsp_plant.
    DELETE FROM zinsp_defect_t.

    " 1. Üretim Yerleri (Plant Master Data)
    lt_plants = VALUE #(
      ( plant = '1000' plant_name = 'Ana Üretim ve Montaj Tesisi'    city = 'İstanbul' )
      ( plant = '2000' plant_name = 'Metal Şekillendirme Fabrikası' city = 'Bandırma' )
      ( plant = '3000' plant_name = 'Yüzey İşlem ve Kaplama Tesisi' city = 'İzmir' )
      ( plant = '4000' plant_name = 'Hassas Talaşlı İmalat Ünitesi' city = 'Bursa' )
      ( plant = '5000' plant_name = 'Lojistik ve Son Kontrol Merkezi' city = 'Ankara' )
    ).

    " 2. Kusur Tipleri (Defect Type Master Data)
    lt_defects = VALUE #(
      ( defect_type = 'WELDING'   description = 'Kaynak Dikişi ve Birleşim Hatası' )
      ( defect_type = 'SURFACE'   description = 'Yüzey Çiziği, Göçük veya Oksidasyon' )
      ( defect_type = 'DIMENSION' description = 'Ölçü ve Geometrik Tolerans Sapması' )
      ( defect_type = 'COATING'   description = 'Boya ve Kaplama Kalınlık Hatası' )
      ( defect_type = 'MATERIAL'  description = 'Hammadde Sertlik veya Alaşım Uygunsuzluğu' )
      ( defect_type = 'PACKAGING' description = 'Ambalaj, Vakum ve Etiketleme Kusuru' )
    ).

    INSERT zinsp_plant    FROM TABLE @lt_plants.
    INSERT zinsp_defect_t FROM TABLE @lt_defects.

    out->write( |Başarılı: { lines( lt_plants ) } Üretim Yeri ve { lines( lt_defects ) } Kusur Tipi eklendi.| ).

  ENDMETHOD.
ENDCLASS.

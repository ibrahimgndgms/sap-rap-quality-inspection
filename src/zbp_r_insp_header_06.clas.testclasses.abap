*"* use this source file for your ABAP unit test classes
CLASS ltc_insp_behavior_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA:
      mo_cds_test_env TYPE REF TO if_cds_test_environment.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      test_severity_5_empty_comment  FOR TESTING,
      test_approve_batch             FOR TESTING,
      test_reject_batch_with_reason  FOR TESTING.

ENDCLASS.


CLASS ltc_insp_behavior_test IMPLEMENTATION.

  METHOD class_setup.
    mo_cds_test_env = cl_cds_test_environment=>create_for_multiple_cds(
      i_for_entities = VALUE #(
        ( i_for_entity = 'ZR_INSP_HEADER_06' )
        ( i_for_entity = 'ZR_INSP_ITEM_06' )
      )
    ).
  ENDMETHOD.

  METHOD class_teardown.
    mo_cds_test_env->destroy( ).
  ENDMETHOD.

  METHOD setup.
    mo_cds_test_env->clear_doubles( ).
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
  ENDMETHOD.

 METHOD test_severity_5_empty_comment.
    " 1. Aktif (non-draft) modda Başlık ve Severity = 5, DefectComment = '' olan Kalemi oluştur
    MODIFY ENTITIES OF zr_insp_header_06 IN LOCAL MODE
      ENTITY Inspection
        CREATE FIELDS ( BatchId Plant InspectionDate )
        WITH VALUE #( (
          %cid           = 'CID_HDR_1'
          BatchId        = 'TEST-BATCH-ITEM-01'
          Plant          = '1000'
          InspectionDate = cl_abap_context_info=>get_system_date( )
        ) )
        CREATE BY \_Items
        FIELDS ( Severity DefectComment )
        WITH VALUE #( (
          %cid_ref = 'CID_HDR_1'
          %target  = VALUE #( (
            %cid          = 'CID_ITM_1'
            Severity      = 5
            DefectComment = ''
          ) )
        ) )
      MAPPED DATA(ls_mapped)
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    " 2. 'on save' validasyonlarını (validateSeverityComment) tetiklemek için kayıt aşamasını çalıştır
    COMMIT ENTITIES BEGIN
      RESPONSE OF zr_insp_header_06
      FAILED DATA(ls_save_failed)
      REPORTED DATA(ls_save_reported).
    COMMIT ENTITIES END.

    " 3. Severity 5 iken açıklama boş olduğu için failed-items tablosunun dolu döndüğünü doğrula
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_save_failed-items
      msg = 'Severity 5 iken açıklama boş bırakıldığında hata dönmeliydi!'
    ).
  ENDMETHOD.

  METHOD test_approve_batch.
    MODIFY ENTITIES OF zr_insp_header_06 IN LOCAL MODE
      ENTITY Inspection
        CREATE FIELDS ( BatchId Plant InspectionDate )
        WITH VALUE #( (
          %cid           = 'CID_AP'
          BatchId        = 'TEST-BATCH-02'
          Plant          = '1000'
          InspectionDate = cl_abap_context_info=>get_system_date( )
        ) )
      MAPPED DATA(ls_mapped).

    MODIFY ENTITIES OF zr_insp_header_06 IN LOCAL MODE
      ENTITY Inspection
        EXECUTE ApproveBatch FROM VALUE #( ( %tky = ls_mapped-inspection[ 1 ]-%tky ) )
      RESULT DATA(lt_action_result)
      FAILED DATA(ls_failed).

    cl_abap_unit_assert=>assert_initial( act = ls_failed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'AP'
      act = lt_action_result[ 1 ]-%param-Status
      msg = 'ApproveBatch sonrası durum AP olmalıdır.'
    ).
  ENDMETHOD.

  METHOD test_reject_batch_with_reason.
    MODIFY ENTITIES OF zr_insp_header_06 IN LOCAL MODE
      ENTITY Inspection
        CREATE FIELDS ( BatchId Plant InspectionDate )
        WITH VALUE #( (
          %cid           = 'CID_RJ'
          BatchId        = 'TEST-BATCH-03'
          Plant          = '1000'
          InspectionDate = cl_abap_context_info=>get_system_date( )
        ) )
      MAPPED DATA(ls_mapped).

    MODIFY ENTITIES OF zr_insp_header_06 IN LOCAL MODE
      ENTITY Inspection
        EXECUTE RejectBatch FROM VALUE #( (
          %tky               = ls_mapped-inspection[ 1 ]-%tky
          %param-RejectReson = 'Yüzey çizik toleransı aşıldı'
        ) )
      RESULT DATA(lt_action_result)
      FAILED DATA(ls_failed).

    cl_abap_unit_assert=>assert_initial( act = ls_failed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'RJ'
      act = lt_action_result[ 1 ]-%param-Status
      msg = 'RejectBatch sonrası durum RJ olmalıdır.'
    ).
  ENDMETHOD.

ENDCLASS.

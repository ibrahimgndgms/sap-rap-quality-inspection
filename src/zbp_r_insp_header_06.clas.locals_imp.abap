CLASS lhc_Inspection DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Inspection RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Inspection RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Inspection RESULT result.

    METHODS ApproveBatch FOR MODIFY
       keys FOR ACTION Inspection~ApproveBatch RESULT result.

    METHODS RejectBatch FOR MODIFY
       keys FOR ACTION Inspection~RejectBatch RESULT result.

    METHODS setDefaultValues FOR DETERMINE ON MODIFY
       keys FOR Inspection~setDefaultValues.

    METHODS validateInspectionDate FOR VALIDATE ON SAVE
       keys FOR Inspection~validateInspectionDate.

ENDCLASS.

CLASS lhc_Inspection IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zr_insp_header_06 IN LOCAL MODE
  ENTITY Inspection
  FIELDS ( status )
  WITH CORRESPONDING #( keys )
  RESULT DATA(headers)
  FAILED failed.

    LOOP AT headers ASSIGNING FIELD-SYMBOL(<header>).
      DATA(lv_state) = if_abap_behv=>fc-o-enabled.

      IF <header>-Status = 'AP' OR <header>-Status = 'RJ'.
        lv_state = if_abap_behv=>fc-o-disabled.
      ENDIF.

      APPEND VALUE #(
          %tky = <header>-%tky
          %update = lv_state
          %delete = lv_state
          %action-ApproveBatch = lv_state
          %action-RejectBatch = lv_state
       ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_authorizations.

    "Burası
    READ ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Inspection
    FIELDS ( Plant )
    WITH CORRESPONDING #( keys )
    RESULT DATA(headers).


    LOOP AT headers ASSIGNING FIELD-SYMBOL(<header>).

      AUTHORITY-CHECK OBJECT 'ZAO_INSP06'
      ID 'ZAF_PLANT' FIELD <header>-Plant
      ID 'ACTVT' FIELD '02'.

      IF sy-subrc NE 0.
        APPEND VALUE #(
          %tky                 = <header>-%tky
          %update              = if_abap_behv=>auth-unauthorized
          %delete              = if_abap_behv=>auth-unauthorized
          %action-ApproveBatch = if_abap_behv=>auth-unauthorized
          %action-RejectBatch  = if_abap_behv=>auth-unauthorized
        ) TO result.


      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD ApproveBatch.

    MODIFY ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Inspection
    UPDATE FIELDS ( status )
    WITH VALUE #( FOR key IN keys (
          %tky = key-%tky
          Status = 'AP'
     ) ).

    READ ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Inspection
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(headers).

    result = VALUE #( FOR header IN headers (
             %tky = header-%tky
             %param = header
     ) ).

  ENDMETHOD.

  METHOD RejectBatch.

    MODIFY ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Inspection
    UPDATE FIELDS ( status RejectReson )
    WITH VALUE #( FOR key IN keys (
          %tky = key-%tky
          Status = 'RJ'
          RejectReson = key-%param-RejectReson
     ) ).

    READ ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Inspection
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(headers).

    result = VALUE #( FOR header IN headers (
             %tky = header-%tky
             %param = header
     ) ).


  ENDMETHOD.

  METHOD setDefaultValues.

    READ ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Inspection
    FIELDS ( Status TotalRiskScore )
    WITH CORRESPONDING #( keys )
    RESULT DATA(headers).

    DELETE headers WHERE status IS NOT INITIAL.
    IF headers IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Inspection
    UPDATE FIELDS ( Status TotalRiskScore )
    WITH VALUE #( FOR header IN headers (
            %tky = header-%tky
            status = 'NW'
            TotalRiskScore = 0
    ) ).

  ENDMETHOD.

  METHOD validateInspectionDate.

    READ ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Inspection
    FIELDS ( InspectionDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(headers).


    DATA(lv_today_date) =  cl_abap_context_info=>get_system_date( ).

    LOOP AT headers INTO DATA(header).
      APPEND VALUE #( %tky = header-%tky
                      %state_area = 'VALIDATE_DATE' ) TO reported-inspection.

      IF header-InspectionDate IS NOT INITIAL AND header-InspectionDate > lv_today_date.
        APPEND VALUE #( %tky = header-%tky ) TO failed-inspection.

        APPEND VALUE #( %tky = header-%tky
                        %state_area = 'VALIDATE_DATE'
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Bakım tarihi ileri bir tarih olamaz'
                               )
                        %element-InspectionDate = if_abap_behv=>mk-on

         ) TO reported-inspection.


      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Items DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalRisk FOR DETERMINE ON MODIFY
       keys FOR Items~calculateTotalRisk.

    METHODS validateSeverityComment FOR VALIDATE ON SAVE
       keys FOR Items~validateSeverityComment.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Items RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR items RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR items RESULT result.

ENDCLASS.

CLASS lhc_Items IMPLEMENTATION.

  METHOD calculateTotalRisk.

    READ ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Items BY \_Header
    FROM CORRESPONDING #( keys )
    LINK DATA(header_links).

    SORT header_links BY target-%tky.
    DELETE DUPLICATES FROM header_links COMPARING target-%tky.


    READ ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Inspection BY \_Items
    FIELDS ( Severity )
    WITH VALUE #( FOR link IN header_links (
        %tky = link-target-%tky
     ) )
     RESULT DATA(all_items).

    DATA headers_to_update TYPE TABLE FOR UPDATE zr_insp_header_06\\Inspection.

    LOOP AT header_links INTO DATA(header_link).

      DATA(lv_total_risk) = 0.

      LOOP AT all_items INTO DATA(item) WHERE InspectionId = header_link-target-InspectionId.
        lv_total_risk += item-Severity.
      ENDLOOP.



      APPEND VALUE #(
          %tky = header_link-target-%tky
          TotalRiskScore = lv_total_risk
       ) TO headers_to_update.


    ENDLOOP.

    MODIFY ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Inspection
    UPDATE FIELDS ( TotalRiskScore )
    WITH  headers_to_update.

  ENDMETHOD.

  METHOD validateSeverityComment.

    READ ENTITIES OF  zr_insp_header_06 IN LOCAL MODE
    ENTITY Items
    FIELDS ( InspectionId Severity DefectComment )
    WITH CORRESPONDING #( keys )
    RESULT DATA(items).

    LOOP AT items INTO DATA(item).
      APPEND VALUE #(  %tky = item-%tky
                       %state_area = 'VALIDATE_COMMENT'
      ) TO reported-items.


      IF item-DefectComment IS INITIAL AND item-Severity EQ 5.
        APPEND VALUE #( %tky = item-%tky ) TO failed-items.

        APPEND VALUE #( %tky = item-%tky
                        %state_area =   'VALIDATE_COMMENT'
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Severity 5 için açıklama girilmek zorundadır'
                               )
                        %element-DefectComment = if_abap_behv=>mk-on
                        %path                  = VALUE #( inspection-%tky = VALUE #( InspectionId = item-InspectionId
                                                                               %is_draft    = item-%is_draft ) )
        ) TO reported-items.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_authorizations.


  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zr_insp_header_06 IN LOCAL MODE
    ENTITY Items
    FIELDS ( Severity )
    WITH CORRESPONDING #( keys )
    RESULT DATA(items)
    FAILED failed.


    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
      IF <item>-Severity EQ 5.
        APPEND VALUE #(
         %tky = <item>-%tky
         %field-DefectComment  = if_abap_behv=>fc-f-mandatory
         ) TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

ENDCLASS.

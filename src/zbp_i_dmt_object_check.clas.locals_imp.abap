CLASS lhc_dmt_checks DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS check_existing FOR MODIFY IMPORTING keys FOR ACTION object~check_existing RESULT result.
    METHODS check_mapping FOR MODIFY IMPORTING keys FOR ACTION object~check_mapping RESULT result.
    METHODS check_map_existing FOR MODIFY IMPORTING keys FOR ACTION object~check_map_existing RESULT result.
    METHODS get_features FOR FEATURES IMPORTING keys REQUEST requested_features FOR object RESULT result.

ENDCLASS.

CLASS lhc_dmt_checks IMPLEMENTATION.

  METHOD check_existing.

       types: BEGIN OF t_options,
                TEXT type c LENGTH 72,
       end of t_options.

       types: BEGIN OF t_fields,
                FIELDNAME type c LENGTH 30,
                OFFSET    type n LENGTH 6,
                LENGTH    type n LENGTH 6,
                TYPE      type c LENGTH 1,
                FIELDTEXT type c LENGTH 60,
              end of t_fields.

       types: begin of t_data,
                WA type c LENGTH 512,
              end of t_data.

       data lt_options type TABLE of t_options.
       data lt_fields  type table of t_fields.
       data lt_data    type table of t_data.

       data ls_option  type t_options.
       data ls_field   type t_fields.

       data lv_field_name  type c LENGTH 20.
       data lv_object_id   type c LENGTH 40.
       data lv_query_table type c LENGTH 30.

    TRY.
        DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
                               i_name = |bp7210_RFC| ).

        DATA(lv_rfc_dest) = lo_rfc_dest->get_destination_name( ).

        lv_query_table = 'LFA1'.

        ls_field-fieldname = 'LIFNR'.
        APPEND ls_field TO lt_fields.

        READ TABLE keys REFERENCE INTO DATA(dr_key) INDEX 1.
        lv_object_id = dr_key->OBJECT_ID.

        lv_field_name = 'LIFNR'.

        ls_option-text = 'LIFNR ='.
        CONCATENATE ls_option-text '''' into ls_option-text SEPARATED BY space.
        CONCATENATE ls_option-text lv_object_id '''' into ls_option-text.

        append ls_option to lt_options.

      CALL FUNCTION 'RFC_READ_TABLE' DESTINATION lv_rfc_dest
        EXPORTING
          query_table          = lv_query_table
        TABLES
          options              = lt_options
          fields               = lt_fields
          data                 = lt_data
        EXCEPTIONS
          table_not_available  = 1
          table_without_data   = 2
          option_not_valid     = 3
          field_not_valid      = 4
          not_authorized       = 5
          data_buffer_exceeded = 6.

      CATCH cx_root INTO DATA(lx_root).
       " out->write( lx_root->get_text( ) ).
    ENDTRY.

 " Modify in local mode: BO-related updates that are not relevant for authorization checks
   if lt_data[] is not INITIAL.
    MODIFY ENTITIES OF zi_dmt_object IN LOCAL MODE
           ENTITY object
              UPDATE FROM VALUE #( FOR key IN keys ( LOGSYSTEM   = key-LOGSYSTEM
                                                     OBJECT_NAME = key-OBJECT_NAME
                                                     OBJECT_ID   = key-OBJECT_ID
                                                     DATA_EXIST  = 'X'
                                                     %control-DATA_EXIST = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.
    endif.

    " Read changed data for action result
    READ ENTITIES OF zi_dmt_object IN LOCAL MODE
         ENTITY object
         FROM VALUE #( FOR key IN keys (  LOGSYSTEM   = key-LOGSYSTEM
                                          OBJECT_NAME = key-OBJECT_NAME
                                          OBJECT_ID   = key-OBJECT_ID
                                          %control = VALUE #(
                                            LOGSYSTEM             = if_abap_behv=>mk-on
                                            OBJECT_NAME           = if_abap_behv=>mk-on
                                            OBJECT_ID             = if_abap_behv=>mk-on
                                            DATA_EXIST            = if_abap_behv=>mk-on
                                            DATA_EXIST_TIMESTAMP  = if_abap_behv=>mk-on
                                            MDG_MAPPING           = if_abap_behv=>mk-on
                                            MDG_MAPPING_TIMESTAMP = if_abap_behv=>mk-on
                                            MAP_LOGSYSTEM         = if_abap_behv=>mk-on
                                            MAP_OBJECT_ID         = if_abap_behv=>mk-on
                                            MAP_DATA_EXIST        = if_abap_behv=>mk-on
                                          ) ) )
         RESULT DATA(lt_objects).

    result = VALUE #( FOR object IN lt_objects ( LOGSYSTEM   = object-LOGSYSTEM
                                                 OBJECT_NAME = object-OBJECT_NAME
                                                 OBJECT_ID   = object-OBJECT_ID
                                                %param    = object
                                              ) ).

  ENDMETHOD.

METHOD check_mapping.

    data lt_search_key type TABLE of ZMDG_S_OBJECT_KEY_BS.
    data lt_matching_objects type ZMDG_T_GET_MATCHING_EASY_BS.

    DATA lv_target_system TYPE c LENGTH 60.
    data lv_id_value      type c LENGTH 120.
    data lv_lifnr         type c LENGTH 10.


    TRY.
        DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
                               i_name = |w17200_RFC| ).

        DATA(lv_rfc_dest) = lo_rfc_dest->get_destination_name( ).

        READ TABLE keys REFERENCE INTO DATA(dr_key) INDEX 1.

        INSERT INITIAL LINE INTO TABLE lt_search_key REFERENCE INTO DATA(dr_search_key).
        dr_search_key->object_type_code = '266'.
        dr_search_key->identifier_key-ident_defining_scheme_code = '892'.
        dr_search_key->identifier_key-business_system_id         = 'BP7CLNT210'.

        lv_lifnr = |{ dr_key->OBJECT_ID ALPHA = OUT }|.

        dr_search_key->identifier_key-id_value = lv_lifnr.

        lv_target_system = 'W17CLNT200'.

        CALL FUNCTION 'MDG_ID_QUERY_MATCHING' DESTINATION lv_rfc_dest
          EXPORTING
            it_search_key         = lt_search_key
            iv_target_system      = lv_target_system
          IMPORTING
            et_matching_objects   = lt_matching_objects
          EXCEPTIONS
            communication_failure = 1
            system_failure        = 2.

        READ TABLE lt_matching_objects REFERENCE INTO DATA(dr_matching_objects) INDEX 1.
        IF sy-subrc EQ 0.

          READ TABLE dr_matching_objects->matching_objects REFERENCE INTO DATA(dr_matching_object) INDEX 1.
          IF sy-subrc EQ 0.

            READ TABLE dr_matching_object->object_identifier REFERENCE INTO DATA(dr_object_identifier) INDEX 1.
            IF sy-subrc EQ 0.

              lv_id_value = dr_object_identifier->id_value.

            ENDIF.
          ENDIF.
        ENDIF.

        if lv_id_value is not INITIAL.


          lv_lifnr = |{ lv_id_value ALPHA = IN }|.
          lv_id_value = lv_lifnr.

             " Modify in local mode: BO-related updates that are not relevant for authorization checks
                MODIFY ENTITIES OF zi_dmt_object IN LOCAL MODE
                       ENTITY object
                          UPDATE FROM VALUE #( FOR key IN keys ( LOGSYSTEM   = key-LOGSYSTEM
                                                                 OBJECT_NAME = key-OBJECT_NAME
                                                                 OBJECT_ID   = key-OBJECT_ID
                                                                 MDG_MAPPING  = 'X'
                                                                 MAP_LOGSYSTEM = 'W17CLNT200'
                                                                 MAP_OBJECT_ID = lv_id_value
                                                                 %control-MDG_MAPPING = if_abap_behv=>mk-on
                                                                 %control-MAP_LOGSYSTEM = if_abap_behv=>mk-on
                                                                 %control-MAP_OBJECT_ID = if_abap_behv=>mk-on ) )
                       FAILED   failed
                       REPORTED reported.
                endif.

                " Read changed data for action result
                READ ENTITIES OF zi_dmt_object IN LOCAL MODE
                     ENTITY object
                     FROM VALUE #( FOR key IN keys (  LOGSYSTEM   = key-LOGSYSTEM
                                                      OBJECT_NAME = key-OBJECT_NAME
                                                      OBJECT_ID   = key-OBJECT_ID
                                                      %control = VALUE #(
                                                        LOGSYSTEM             = if_abap_behv=>mk-on
                                                        OBJECT_NAME           = if_abap_behv=>mk-on
                                                        OBJECT_ID             = if_abap_behv=>mk-on
                                                        DATA_EXIST            = if_abap_behv=>mk-on
                                                        DATA_EXIST_TIMESTAMP  = if_abap_behv=>mk-on
                                                        MDG_MAPPING           = if_abap_behv=>mk-on
                                                        MDG_MAPPING_TIMESTAMP = if_abap_behv=>mk-on
                                                        MAP_LOGSYSTEM         = if_abap_behv=>mk-on
                                                        MAP_OBJECT_ID         = if_abap_behv=>mk-on
                                                        MAP_DATA_EXIST        = if_abap_behv=>mk-on
                                                      ) ) )
                     RESULT DATA(lt_objects).

                result = VALUE #( FOR object IN lt_objects ( LOGSYSTEM   = object-LOGSYSTEM
                                                             OBJECT_NAME = object-OBJECT_NAME
                                                             OBJECT_ID   = object-OBJECT_ID
                                                            %param    = object
                                                          ) ).

      CATCH cx_root INTO DATA(lx_root).
       " out->write( lx_root->get_text( ) ).
    ENDTRY.

ENDMETHOD.

METHOD check_map_existing.

       types: BEGIN OF t_options,
                TEXT type c LENGTH 72,
       end of t_options.

       types: BEGIN OF t_fields,
                FIELDNAME type c LENGTH 30,
                OFFSET    type n LENGTH 6,
                LENGTH    type n LENGTH 6,
                TYPE      type c LENGTH 1,
                FIELDTEXT type c LENGTH 60,
              end of t_fields.

       types: begin of t_data,
                WA type c LENGTH 512,
              end of t_data.

       data lt_options type TABLE of t_options.
       data lt_fields  type table of t_fields.
       data lt_data    type table of t_data.

       data ls_option  type t_options.
       data ls_field   type t_fields.

       data lv_field_name  type c LENGTH 20.
       data lv_object_id   type c LENGTH 40.
       data lv_query_table type c LENGTH 30.

    TRY.
        DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
                               i_name = |w17200_RFC| ).

        DATA(lv_rfc_dest) = lo_rfc_dest->get_destination_name( ).

        lv_query_table = 'LFA1'.

        ls_field-fieldname = 'LIFNR'.
        APPEND ls_field TO lt_fields.

        READ ENTITIES OF zi_dmt_object IN LOCAL MODE
             ENTITY object
             FROM VALUE #( FOR key IN keys (  LOGSYSTEM   = key-LOGSYSTEM
                                              OBJECT_NAME = key-OBJECT_NAME
                                              OBJECT_ID   = key-OBJECT_ID
                                              %control = VALUE #(
                                                MAP_OBJECT_ID         = if_abap_behv=>mk-on
                                              ) ) )
             RESULT DATA(lt_objects).

        READ TABLE lt_objects REFERENCE INTO DATA(dr_objects) INDEX 1.
        CHECK sy-subrc eq 0.

        if dr_objects->MAP_OBJECT_ID is not INITIAL.

            lv_object_id = dr_objects->MAP_OBJECT_ID.

            lv_field_name = 'LIFNR'.

            ls_option-text = 'LIFNR ='.
            CONCATENATE ls_option-text '''' into ls_option-text SEPARATED BY space.
            CONCATENATE ls_option-text lv_object_id '''' into ls_option-text.

            append ls_option to lt_options.

          CALL FUNCTION 'RFC_READ_TABLE' DESTINATION lv_rfc_dest
            EXPORTING
              query_table          = lv_query_table
            TABLES
              options              = lt_options
              fields               = lt_fields
              data                 = lt_data
            EXCEPTIONS
              table_not_available  = 1
              table_without_data   = 2
              option_not_valid     = 3
              field_not_valid      = 4
              not_authorized       = 5
              data_buffer_exceeded = 6.

      endif.

      CATCH cx_root INTO DATA(lx_root).
       " out->write( lx_root->get_text( ) ).
    ENDTRY.

 " Modify in local mode: BO-related updates that are not relevant for authorization checks
   if lt_data[] is not INITIAL.
    MODIFY ENTITIES OF zi_dmt_object IN LOCAL MODE
           ENTITY object
              UPDATE FROM VALUE #( FOR key IN keys ( LOGSYSTEM   = key-LOGSYSTEM
                                                     OBJECT_NAME = key-OBJECT_NAME
                                                     OBJECT_ID   = key-OBJECT_ID
                                                     MAP_DATA_EXIST  = 'X'
                                                     %control-MAP_DATA_EXIST = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.
    endif.

    " Read changed data for action result
    READ ENTITIES OF zi_dmt_object IN LOCAL MODE
         ENTITY object
         FROM VALUE #( FOR key IN keys (  LOGSYSTEM   = key-LOGSYSTEM
                                          OBJECT_NAME = key-OBJECT_NAME
                                          OBJECT_ID   = key-OBJECT_ID
                                          %control = VALUE #(
                                            LOGSYSTEM             = if_abap_behv=>mk-on
                                            OBJECT_NAME           = if_abap_behv=>mk-on
                                            OBJECT_ID             = if_abap_behv=>mk-on
                                            DATA_EXIST            = if_abap_behv=>mk-on
                                            DATA_EXIST_TIMESTAMP  = if_abap_behv=>mk-on
                                            MDG_MAPPING           = if_abap_behv=>mk-on
                                            MDG_MAPPING_TIMESTAMP = if_abap_behv=>mk-on
                                            MAP_LOGSYSTEM         = if_abap_behv=>mk-on
                                            MAP_OBJECT_ID         = if_abap_behv=>mk-on
                                            MAP_DATA_EXIST        = if_abap_behv=>mk-on
                                          ) ) )
         RESULT lt_objects.

    result = VALUE #( FOR object IN lt_objects ( LOGSYSTEM   = object-LOGSYSTEM
                                                 OBJECT_NAME = object-OBJECT_NAME
                                                 OBJECT_ID   = object-OBJECT_ID
                                                %param    = object
                                              ) ).

ENDMETHOD.

  METHOD get_features.

    READ ENTITY zi_dmt_object FROM VALUE #( FOR keyval IN keys
                                                      (  %key = keyval-%key
                                                         %control-LOGSYSTEM   = keyval-LOGSYSTEM
                                                         %control-OBJECT_NAME = keyval-OBJECT_NAME
                                                         %control-OBJECT_ID   = keyval-OBJECT_ID ) )
                                RESULT DATA(lt_dmt_objects).


    result = VALUE #( FOR ls_dmt_object IN lt_dmt_objects
                       ( %key = ls_dmt_object-%key
                         %features-%action-check_existing = COND #( WHEN ls_dmt_object-DATA_EXIST = 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                      ) ).

  ENDMETHOD.

ENDCLASS.

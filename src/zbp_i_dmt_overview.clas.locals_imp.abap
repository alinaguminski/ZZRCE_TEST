CLASS lhc_dmt_checks DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS collect_data FOR MODIFY IMPORTING keys FOR ACTION object~collect_data RESULT result.
    METHODS get_features FOR FEATURES IMPORTING keys REQUEST requested_features FOR object RESULT result.

ENDCLASS.

CLASS lhc_dmt_checks IMPLEMENTATION.

  METHOD collect_data.


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

        types: begin of t_where,
                 fieldname type zdmt_mn_fieldname,
                 fcond     type string,
               end of t_where.

       data lt_options type TABLE of t_options.
       data lt_fields  type table of t_fields.
       data lt_data    type table of t_data.
       data lt_where   type TABLE of t_where.

       data ls_option  type t_options.
       data ls_field   type t_fields.

       data lv_field_name  type c LENGTH 20.
       data lv_object_id   type c LENGTH 40.
       data lv_query_table type c LENGTH 30.
       data lv_fieldname   type c LENGTH 30.

    TRY.
        DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
                               i_name = |bp7210_RFC| ).

        DATA(lv_rfc_dest) = lo_rfc_dest->get_destination_name( ).

        READ TABLE keys REFERENCE INTO DATA(dr_key) INDEX 1.

        select *
          from zi_dmt_extr_cnf
         where logsystem   eq @dr_key->logsystem
           and object_name eq @dr_key->object_name
          into TABLE @data(lt_extr_cnf).

        sort lt_extr_cnf.

        loop at lt_extr_cnf REFERENCE INTO DATA(dr_extr_cnf).

            READ table lt_where REFERENCE INTO DATA(dr_where) with key fieldname = dr_extr_cnf->fieldname.
            if sy-subrc eq 0.
                CONCATENATE dr_where->fcond ',' into dr_where->fcond.
                CONCATENATE dr_where->fcond '''' into dr_where->fcond SEPARATED BY space.
                CONCATENATE dr_where->fcond dr_extr_cnf->fieldval '''' into dr_where->fcond.
            else.
                insert INITIAL LINE INTO TABLE lt_where REFERENCE INTO dr_where.
                dr_where->fieldname = dr_extr_cnf->fieldname.
                CONCATENATE '''' dr_extr_cnf->fieldval '''' into dr_where->fcond.
            endif.
        endloop.

        loop at lt_where REFERENCE INTO dr_where.

          CONCATENATE '(' dr_where->fcond ')' into dr_where->fcond.
          CONCATENATE 'IN' dr_where->fcond into dr_where->fcond SEPARATED BY space.
          CONCATENATE dr_where->fieldname dr_where->fcond into dr_where->fcond SEPARATED BY space.

          insert INITIAL LINE INTO TABLE lt_options REFERENCE INTO DATA(dr_options).
          dr_options->text = dr_where->fcond.

          if lines( lt_options ) gt 1.
            CONCATENATE 'AND' dr_options->text into dr_options->text SEPARATED BY space.
          endif.
        endloop.

        lv_query_table = 'BSEG'.

        ls_field-fieldname = 'LIFNR'.
        APPEND ls_field TO lt_fields.

        "loop at lt_extr_cnf REFERENCE INTO dr_extr_cnf.

         "   if lt_options is not INITIAL.
          "    if lv_fieldname eq dr_extr_cnf->fieldname.
           "     ls_option-text = 'OR'.
            "  else.
             "   ls_option-text = 'AND'.
              "endif.
            "endif.

            "CONCATENATE ls_option-text dr_extr_cnf->fieldname '=' into ls_option-text SEPARATED BY space.
            "CONCATENATE ls_option-text '''' into ls_option-text SEPARATED BY space.
            "CONCATENATE ls_option-text dr_extr_cnf->fieldval '''' into ls_option-text.
            "append ls_option to lt_options.
            "clear ls_option-text.

            "lv_fieldname = dr_extr_cnf->fieldname.

        "ENDLOOP.



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

     sort lt_data.
     delete ADJACENT DUPLICATES FROM lt_data COMPARING ALL FIELDS.

     loop at lt_data REFERENCE INTO DATA(dr_data).

        CHECK dr_data->* is not INITIAL.

        lv_object_id = dr_data->*.

        data ls_object type zdmt_d_object.

        select single *
          from zi_dmt_object
         where logsystem   eq 'BP7CLNT210'
           and object_name eq 'VENDOR'
           and object_id   eq @lv_object_id
          into @data(ls_object_chk).

        if sy-subrc ne 0.

        ls_object-logsystem = 'BP7CLNT210'.
        ls_object-object_name = 'VENDOR'.
        ls_object-object_id = lv_object_id.

        insert zdmt_d_object from @ls_object.

        endif.

     endloop.

*    MODIFY ENTITIES OF zi_dmt_object IN LOCAL MODE
*           ENTITY object
*              UPDATE FROM VALUE #( FOR key IN keys ( LOGSYSTEM   = key-LOGSYSTEM
*                                                     OBJECT_NAME = key-OBJECT_NAME
*                                                     OBJECT_ID   = key-OBJECT_ID
*                                                     DATA_EXIST  = 'X'
*                                                     %control-DATA_EXIST = if_abap_behv=>mk-on ) )
*           FAILED   failed
*           REPORTED reported.
    endif.

    " Read changed data for action result
*    READ ENTITIES OF zi_dmt_object IN LOCAL MODE
*         ENTITY object
*         FROM VALUE #( FOR key IN keys (  LOGSYSTEM   = key-LOGSYSTEM
*                                          OBJECT_NAME = key-OBJECT_NAME
*                                          OBJECT_ID   = key-OBJECT_ID
*                                          %control = VALUE #(
*                                            LOGSYSTEM             = if_abap_behv=>mk-on
*                                            OBJECT_NAME           = if_abap_behv=>mk-on
*                                            OBJECT_ID             = if_abap_behv=>mk-on
*                                            DATA_EXIST            = if_abap_behv=>mk-on
*                                            DATA_EXIST_TIMESTAMP  = if_abap_behv=>mk-on
*                                            MDG_MAPPING           = if_abap_behv=>mk-on
*                                            MDG_MAPPING_TIMESTAMP = if_abap_behv=>mk-on
*                                            MAP_LOGSYSTEM         = if_abap_behv=>mk-on
*                                            MAP_OBJECT_ID         = if_abap_behv=>mk-on
*                                            MAP_DATA_EXIST        = if_abap_behv=>mk-on
*                                          ) ) )
*         RESULT DATA(lt_objects).

*    result = VALUE #( FOR object IN lt_objects ( LOGSYSTEM   = object-LOGSYSTEM
*                                                 OBJECT_NAME = object-OBJECT_NAME
*                                                 OBJECT_ID   = object-OBJECT_ID
*                                                %param    = object
*                                              ) ).


  ENDMETHOD.

  METHOD get_features.

      READ ENTITY zi_dmt_object FROM VALUE #( FOR keyval IN keys
                                                      (  %key = keyval-%key
                                                         %control-LOGSYSTEM   = keyval-LOGSYSTEM
                                                         %control-OBJECT_NAME = keyval-OBJECT_NAME ) )
                                RESULT DATA(lt_dmt_objects).


    result = VALUE #( FOR ls_dmt_object IN lt_dmt_objects
                       ( %key = ls_dmt_object-%key
                         %features-%action-collect_data = if_abap_behv=>fc-o-disabled
                      ) ).


  ENDMETHOD.

  ENDCLASS.

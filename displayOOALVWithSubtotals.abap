 DATA: lo_table       TYPE REF TO cl_salv_table,
       lo_event       TYPE REF TO cl_salv_events_table,
       lo_functions   TYPE REF TO cl_salv_functions,
       lo_aggrs       TYPE REF TO cl_salv_aggregations,
       lo_sort        TYPE REF TO cl_salv_sorts,
       lo_sort_column TYPE REF TO cl_salv_sort.

  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = lo_table
    CHANGING
      t_table = gt_data.

* Just to show that using the CALL METHOD statement is not the only possible way.
  lo_event = lo_table->get_event( ).
  SET HANDLER lcl_event_handler=>on_added_function FOR lo_event.

  lo_functions = lo_table->get_functions( ).
  lo_functions->set_all( if_salv_c_bool_sap=>true ).

  PERFORM zf_change_column USING lo_table:  '15' 'PERNR'               'Matrícula',
                                            '40' 'CNAME'               'Nome',
                                            '10' 'WERKS'               'Área de RH',
                                            '20' 'PTEXTGRP'            'Grupo EE',
                                            '20' 'PTEXTSUB'            'Subgrupo EE',
                                            '10' 'KOSTL'               'Centro de custo',
                                            '15' 'GSBER'               'Mão de obra',
                                            '12' 'TPFER'               'Tipo de férias',
                                            '15' 'SAL_DIA'             'Salário dia',
                                            '15' 'SAL_HORA'            'Salário hora',
                                            '10' 'DIASFER'             'Dias de férias',
                                            '15' 'HORASMED'            'Horas p/ Médias',
                                            '15' 'PROVFER'             'Prov. Férias',
                                            '15' 'PROVFERFOLHA'        'Prov. Férias Folha',
                                            '15' 'DIFPROVFER'          'Diferença',
                                            '15' 'PROVMEDIAS'          'Prov. Médias',
                                            '15' 'PROVMEDFOLHA'        'Prov. Médias Folha',
                                            '15' 'DIFPROVMED'          'Diferença',
                                            '15' 'PROVCONTER'          'Prov. Contribuição ER',
                                            '15' 'PROVERFOLHA'         'Prov. ER Folha',
                                            '15' 'DIFPROVER'           'Diferença',
                                            '15' 'PROVCONTERMEDIAS'    'Prov. Contrib. ER (Médias)',
                                            '15' 'PROVERFOLHAMEDIAS'   'Prov. ER Folha (Méd.)',
                                            '15' 'DIFPROVERMEDIAS'     'Diferença',
                                            '15' 'PROVFGTS'            'Prov. FGTS',
                                            '15' 'PROVFGTSFOLHA'       'Prov. FGTS Folha',
                                            '15' 'DIFPROVFGTS'         'Diferença',
                                            '15' 'PROVFGTSMEDIAS'      'Prov. FGTS (Médias)',
                                            '15' 'PROVFGTSFOLHAMEDIAS' 'Prov. FGTS Folha (Méd.)',
                                            '15' 'DIFPROVFGTSMEDIAS'   'Diferença',

                                            '18' 'VR_ADIA'  'Valor Adiantado',
                                            '15' 'PARCEL'   'N° Parcelas',
                                            '18' 'VR_DESC'  'Val. Descontado',
                                            '18' 'SALDO'    'Saldo Pendente',
                                            '15' 'PARC_P'   'N° Parc. Pend'.

* Add totals.
  lo_aggrs = lo_table->get_aggregations( ). "get aggregations

  TRY.
      CALL METHOD lo_aggrs->add_aggregation
        EXPORTING
          columnname  = 'PROVFERFOLHA'
          aggregation = if_salv_c_aggregation=>total.

    CATCH cx_salv_data_error cx_salv_not_found cx_salv_existing.                          "#EC NO_HANDLER
  ENDTRY.

* Add subtotals.
  CALL METHOD lo_table->get_sorts
    RECEIVING
      value = lo_sort.

  TRY.
    CALL METHOD lo_sort->add_sort
      EXPORTING
        columnname = 'PERNR' "sort column always keyfield
      RECEIVING
        value      = lo_sort_column.

    CALL METHOD lo_sort_column->set_subtotal "add subtotal
      EXPORTING
        value = if_salv_c_bool_sap=>true.
        CATCH cx_salv_data_error cx_salv_not_found cx_salv_existing.                          "#EC NO_HANDLER
  ENDTRY.

  CALL METHOD lo_table->display.
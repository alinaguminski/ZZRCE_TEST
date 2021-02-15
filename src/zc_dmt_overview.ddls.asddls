@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View - DMT: Overview Page'

@UI: {
 headerInfo: { 
   typeName: 'DMT_OVERVIEW', 
   typeNamePlural: 'DMT Overview Page', 
   title: { 
     label: 'Object Name', 
     type: #STANDARD, 
     value: 'OBJECT_NAME' 
     }
  } 
}

@UI.badge: { 
    title: {
        label: 'Sales Order',
        value: 'LOGSYSTEM'   -- Reference to element in element list
    },
    headLine: {
        label: 'Customer',
        value: 'OBJECT_NAME'    -- Reference to element in element list
    }
}

@Search.searchable: true
define root view entity ZC_DMT_OVERVIEW
  as projection on ZI_DMT_OVERVIEW
{

      @UI.facet: [ { id:              'DMT_Object',
                     purpose:         #STANDARD,
                     type:            #COLLECTION,
                     label:           'DMT Object',
                     position:        10 },
                     
                   { id:              'Basic_Data',
                     purpose:         #STANDARD,
                     type:            #FIELDGROUP_REFERENCE,
                     label:           'Basic Data',
                     targetQualifier: 'Basic',
                     position:        20 },   
                     
                   { id:              'Mapping',
                     purpose:         #STANDARD,
                     type:            #FIELDGROUP_REFERENCE,
                     label:           'Mapping',
                     targetQualifier: 'Mapping',
                     position:        30 } ]

      @UI: {
          lineItem:       [ { position: 10, importance: #HIGH } ],
          identification: [ { position: 10 } ],
          selectionField: [ { position: 10 } ],
          fieldGroup:     [ { qualifier: 'Basic', position: 20, importance: #HIGH } ] }
      @Search.defaultSearchElement: true
      key logsystem             as LOGSYSTEM,
      
      @UI: {
          lineItem:       [ { position: 20, importance: #HIGH } ],
          identification: [ { position: 20 } ],
          selectionField: [ { position: 20 } ],
          fieldGroup:     [ { qualifier: 'Basic', position: 10, importance: #HIGH } ] }   
      @Search.defaultSearchElement: true
      key object_name           as OBJECT_NAME,
      
      @UI: {
          lineItem:       [ { position: 30, importance: #HIGH } ], 
          identification: [ { position: 30 } ],
          selectionField: [ { position: 30 } ],
          fieldGroup:     [ { qualifier: 'Basic', position: 30, importance: #HIGH } ] }      
      @Search.defaultSearchElement: true  
      key object_id             as OBJECT_ID,
      
      @UI: {
            lineItem:       [ { position: 30, importance: #HIGH },
                              { label: 'Total Objects' } ],
          identification: [ { position: 30, label: 'Total Objects' } ],
          fieldGroup:     [ { qualifier: 'Basic', position: 30, importance: #MEDIUM } ]  }
      DistinctObjectName as DistinctObjectName,
      
      @UI: {
            lineItem:       [ { position: 30, importance: #HIGH },
                              { label: 'Total Objects 2' } ],
          identification: [ { position: 30, label: 'Total Objects 2' } ],
          fieldGroup:     [ { qualifier: 'Basic', position: 30, importance: #MEDIUM } ]  }
      DistinctObjects as DistinctObjects,
      
      @UI: {
            lineItem:       [ { position: 40, importance: #HIGH },
                              { type: #FOR_ACTION, dataAction: 'check_existing', label: 'Check Existing' } ],
          identification: [ { position: 40, label: 'Data Exist' } ],
          fieldGroup:     [ { qualifier: 'Basic', position: 50, importance: #MEDIUM } ]  }
          data_exist            as DATA_EXIST, 
      @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM },
                            { type: #FOR_ACTION, dataAction: 'check_mapping', label: 'Check Mapping' } ],
          identification: [ { position: 60, label: 'MDG Mapping' } ],
          fieldGroup:     [ { qualifier: 'Mapping', position: 10, importance: #MEDIUM } ] }  
          mdg_mapping           as MDG_MAPPING,
      @UI: {
          lineItem:       [ { position: 80, importance: #MEDIUM } ],
          identification: [ { position: 80 } ],  
          fieldGroup:     [ { qualifier: 'Mapping', position: 30, importance: #MEDIUM } ] }
          map_object_id         as MAP_OBJECT_ID,
          
      @UI: {
          lineItem:       [ { position: 90, importance: #MEDIUM },
                            { type: #FOR_ACTION, dataAction: 'check_map_existing', label: 'Check Map Data Existing' } ],
          identification: [ { position: 90 } ],
          fieldGroup:     [ { qualifier: 'Mapping', position: 40, importance: #MEDIUM } ] }  
          map_data_exist        as MAP_DATA_EXIST      

}

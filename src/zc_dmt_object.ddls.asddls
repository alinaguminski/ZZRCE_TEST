@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View - DMT: Object'

@UI: {
 headerInfo: { 
   typeName: 'DMT_Object', 
   typeNamePlural: 'DMT Objects', 
   title: { 
     label: 'Object ID', 
     type: #STANDARD, 
     value: 'Object_ID' 
     }
   //description: {
     //label: 'Object',
     //value: 'OBJECT_NAME'
    //}
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
    },
    mainInfo: {
        label: 'Object ID',
        value: 'OBJECT_ID'    -- Reference to element in element list
    }
}

@Search.searchable: true
define root view entity ZC_DMT_OBJECT
  as projection on ZI_DMT_OBJECT
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
                     //parentId:        'DMT_Object',
                     targetQualifier: 'Basic',
                     position:        20 },   
                     
                   { id:              'Mapping',
                     purpose:         #STANDARD,
                     type:            #FIELDGROUP_REFERENCE,
                     label:           'Mapping',
                     //parentId:        'DMT_Object',
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
          lineItem:       [ { position: 70, importance: #MEDIUM } ],
          identification: [ { position: 70 } ],
          fieldGroup:     [ { qualifier: 'Mapping', position: 20, importance: #MEDIUM } ] }  
          map_logsystem         as MAP_LOGSYSTEM,
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

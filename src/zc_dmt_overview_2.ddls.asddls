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
define root view entity ZC_DMT_OVERVIEW_2
  as projection on ZI_DMT_OVERVIEW_2
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
          lineItem:       [ { position: 20, importance: #HIGH },
                            { type: #FOR_ACTION, dataAction: 'collect_data', label: 'Collect Data' } ],
          identification: [ { position: 20 } ],
          selectionField: [ { position: 20 } ],
          fieldGroup:     [ { qualifier: 'Basic', position: 10, importance: #HIGH } ] }   
      @Search.defaultSearchElement: true
      key object_name           as OBJECT_NAME,
      
      @UI: {
          lineItem:       [ { position: 30, importance: #HIGH, label: 'Total Objects' } ], 
          identification: [ { position: 30, label: 'Total Objects' } ],
          selectionField: [ { position: 30 } ],
          fieldGroup:     [ { qualifier: 'Basic', position: 30, importance: #HIGH, label: 'Total Objects' } ] }      
      @Search.defaultSearchElement: true  
      object_count             as object_count,

      @UI: {
          lineItem:       [ { position: 40, importance: #HIGH, label: 'Mapping' } ], 
          identification: [ { position: 40, label: 'Mapping' } ],
          selectionField: [ { position: 40 } ],
          fieldGroup:     [ { qualifier: 'Mapping', position: 10, importance: #HIGH, label: 'Mapping' } ] }      
      @Search.defaultSearchElement: true  
      map_object_count             as map_object_count

}

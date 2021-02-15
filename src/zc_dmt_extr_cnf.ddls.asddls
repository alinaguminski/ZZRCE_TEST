@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View - DMT: Extraction Config'

@UI: {
 headerInfo: { 
   typeName: 'DMT_EXTR_CNF', 
   typeNamePlural: 'DMT Extraction Config', 
   title: { 
     label: 'Object Name', 
     type: #STANDARD, 
     value: 'OBJECT_NAME' 
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
    }
}

@Search.searchable: true
define root view entity ZC_DMT_EXTR_CNF
  as projection on ZI_DMT_EXTR_CNF 
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
                     
                   { id:              'Extraction_Data',
                     purpose:         #STANDARD,
                     type:            #FIELDGROUP_REFERENCE,
                     label:           'Extraction Data',
                     targetQualifier: 'Extraction',
                     position:        30 } ]

      @UI: {
          lineItem:       [ { position: 10, importance: #HIGH } ],
          identification: [ { position: 10 } ],
          selectionField: [ { position: 10 } ],
          fieldGroup:     [ { qualifier: 'Basic', position: 10, importance: #HIGH } ] }
      @Search.defaultSearchElement: true
      key logsystem             as LOGSYSTEM,
      
      @UI: {
          lineItem:       [ { position: 20, importance: #HIGH } ],
          identification: [ { position: 20 } ],
          selectionField: [ { position: 20 } ],
          fieldGroup:     [ { qualifier: 'Basic', position: 20, importance: #HIGH } ] }   
      @Search.defaultSearchElement: true
      key object_name           as OBJECT_NAME,
      
      @UI: {
          lineItem:       [ { position: 30, importance: #HIGH } ], 
          identification: [ { position: 30 } ],
          selectionField: [ { position: 30 } ],
          fieldGroup:     [ { qualifier: 'Extraction', position: 10, importance: #HIGH } ] }      
      @Search.defaultSearchElement: true  
      key tabname             as tabname,
      
      @UI: {
          lineItem:       [ { position: 40, importance: #HIGH } ],
          identification: [ { position: 40 } ],
          fieldGroup:     [ { qualifier: 'Extraction', position: 20, importance: #HIGH } ] }
      key fieldname            as fieldname, 
      
      @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM } ],
          identification: [ { position: 60 } ],
          fieldGroup:     [ { qualifier: 'Extraction', position: 30, importance: #HIGH } ] }  
      key fieldval           as fieldval   

}

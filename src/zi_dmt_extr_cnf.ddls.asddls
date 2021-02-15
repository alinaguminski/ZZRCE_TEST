@AbapCatalog.sqlViewName: 'ZVI_DMT_EXTR_CNF'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'DMT: Extraction Config'
define root view ZI_DMT_EXTR_CNF 
  as select from zdmt_extr_cnf 
  
{
    
key logsystem,
key object_name,
key tabname,
key fieldname,
key fieldval
    
}

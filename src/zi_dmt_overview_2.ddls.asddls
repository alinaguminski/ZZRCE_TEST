@AbapCatalog.sqlViewName: 'ZVI_DMTOVERVIEW2'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface View - Overview Page'
define root view ZI_DMT_OVERVIEW_2 as select from zdmt_d_object {
    
key logsystem,
key object_name,
count(distinct object_id) as object_count,
count(distinct map_object_id) as map_object_count 
//sum(object_count) as sum_object_count
}
group by logsystem, object_name;

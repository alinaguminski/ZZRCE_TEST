@AbapCatalog.sqlViewName: 'ZVI_DMT_OBJECT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface View - DMT Object'
define root view ZI_DMT_OBJECT
  as select from zdmt_d_object

{

key logsystem,
key object_name,
key object_id,
data_exist,
data_exist_timestamp,
mdg_mapping,
mdg_mapping_timestamp,
map_logsystem,
map_object_id,
map_data_exist

}

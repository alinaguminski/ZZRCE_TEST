@AbapCatalog.sqlViewName: 'ZVI_DMT_OVERVIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface View - Overview Page'
define root view ZI_DMT_OVERVIEW as select from zdmt_d_object {
    
key logsystem,
key object_name,
key object_id,

@Aggregation.referenceElement: ['object_name']
@Aggregation.default: #COUNT_DISTINCT
cast( 1 as abap.int4 ) as DistinctObjectName,

@Aggregation.referenceElement: ['object_id']
@Aggregation.default: #COUNT_DISTINCT
cast( 1 as abap.int4 ) as DistinctObjects,

data_exist,
@Aggregation.referenceElement: ['data_exist']
@Aggregation.default: #COUNT_DISTINCT
cast( 1 as abap.int4 ) as DistinctDataExist,

mdg_mapping,
@Aggregation.referenceElement: ['mdg_mapping']
@Aggregation.default: #COUNT_DISTINCT
cast( 1 as abap.int4 ) as DistinctMdgMapping,

map_object_id,
@Aggregation.referenceElement: ['map_object_id']
@Aggregation.default: #COUNT_DISTINCT
cast( 1 as abap.int4 ) as DistinctMapObjectID,

map_data_exist,
@Aggregation.referenceElement: ['map_data_exist']
@Aggregation.default: #COUNT_DISTINCT
cast( 1 as abap.int4 ) as DistinctMapDataExist

}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Plant Value Help Data Definition'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PLANT_VH as select from ZINSP_PLANT
{
    key plant as Plant,
    plant_name as PlantName,
    city as City
}

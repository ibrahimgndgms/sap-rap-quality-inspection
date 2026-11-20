@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inspection Projection View'
@Metadata.allowExtensions: true
define root view entity ZC_INSP_HEADER_06
  provider contract transactional_query as projection on ZR_INSP_HEADER_06
{
    key InspectionId,
    BatchId,
    @Consumption.valueHelpDefinition: [{ entity : {name : 'ZI_PLANT_VH', element : 'Plant' }, 
    useForValidation: true }]
    Plant,
    RejectReson,
    InspectionDate,
    Status,
    TotalRiskScore,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    StatusCriticality,
    /* Associations */
    _Items : redirected to composition child ZC_INSP_ITEMS_06 
}

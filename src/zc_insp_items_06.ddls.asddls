@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: ':Quality Items Projection View'
@Metadata.allowExtensions: true
define view entity ZC_INSP_ITEMS_06
  as projection on ZR_INSP_ITEM_06

{
  key ItemId,
      InspectionId,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_DEFECT_TYPE_VH',
              element: 'DefectType'
          },useForValidation: true
      }]
      DefectType,
      Severity,
      DefectComment,
      LocalLastChangedAt,
      /* Associations */
      _Header : redirected to parent ZC_INSP_HEADER_06
}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Defect Type Value Help Data Definition'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_DEFECT_TYPE_VH
  as select from zinsp_defect_t
{
  key defect_type as DefectType,
      description as Description
}

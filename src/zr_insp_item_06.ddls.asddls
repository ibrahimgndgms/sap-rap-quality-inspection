@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Quality Inspection Defect Items'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_INSP_ITEM_06 as select from zinsp_items_06
association to parent zr_insp_header_06 as _Header on $projection.InspectionId = _Header.InspectionId
{
    key item_id as ItemId,
    inspection_id as InspectionId,
    defect_type as DefectType,
    severity as Severity,
    defect_comment as DefectComment,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
    _Header
}

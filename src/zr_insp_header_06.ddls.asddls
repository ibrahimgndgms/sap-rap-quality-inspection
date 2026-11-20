@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: ': Quality Inspection Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZR_INSP_HEADER_06 as select from zinsp_header_06
composition [0..*] of ZR_INSP_ITEM_06 as _Items
{
    key inspection_id as InspectionId,
    batch_id as BatchId,
    plant as Plant,
    inspection_date as InspectionDate,
    reject_reson  as RejectReson,
    status as Status,
    total_risk_score as TotalRiskScore,
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.lastChangedBy: true
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
    case status when 'AP' then 3
    when 'RJ' then 1
    else 2
    end as StatusCriticality,
    _Items // Make association public
}

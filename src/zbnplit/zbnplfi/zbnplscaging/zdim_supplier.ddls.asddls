@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Suppliers'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'Supplier'

define view entity ZDIM_Supplier
  as select from I_Supplier as A
 left outer join I_RegionText as _RegionText on  A.Region  = _RegionText.Region 
                                                    and A.Country = _RegionText.Country
                                                    and _RegionText.Language=$session.system_language
{
      @ObjectModel.text.element: ['SupplierName']
  key A.Supplier,
  
      @Semantics.text:true
      A.SupplierName,
      
      @Semantics.text:true
      @EndUserText.label: 'GSTIN'
      A.TaxNumber3 as GSTIN,

      @EndUserText.label: 'City'
      A.CityName   as City,

      @EndUserText.label: 'State'
      _RegionText.RegionName  as Region,

      @EndUserText.label: 'Country'
      A.Country

}

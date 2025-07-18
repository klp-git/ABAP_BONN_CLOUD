@EndUserText.label: 'Copy TABLE FOR TAX CODE'
define abstract entity ZD_CopyTableForTaxCodeP
{
  @EndUserText.label: 'New Country'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Country' )
  Country : ZDE_COUNTRY;
  @EndUserText.label: 'New WITHHOLDINGTAXCODE'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Officialwhldgtaxcode' )
  Officialwhldgtaxcode : ZDEWITHHOLDINGTAX;
  @EndUserText.label: 'New WithHolding Tax Code'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Withholdingtaxcode' )
  Withholdingtaxcode : ZDE_WITHHOLDINGTAXCODE;
  
}

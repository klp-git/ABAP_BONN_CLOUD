@EndUserText.label: 'Table Valued Function - GL Statement'
@ClientHandling.type:  #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function ZTBLF_GLAccountStatement
  with parameters
    pCompanyCode : abap.char(4),
    pGLAccount   : abap.char(10),
    pFromDate    : abap.dats,
    pToDate      : abap.dats,
    @Consumption.defaultValue: 'N'
    pIsRevDoc    : abap.char(1)
returns
{
  CLIENT                      : mandt;
  FISCALYEAR                  : abap.numc(4);
  COMPANYCODE                 : abap.char(4);
  GLACCOUNT                   : abap.char(10);
  GLACCOUNTNAME               : abap.char(20);
  SRNO                        : abap.int4;
  POSTINGDATE                 : abap.dats;
  DOCUMENTDATE                : abap.dats;
  ACCOUNTINGDOCUMENTTYPE      : abap.char(2);
  ACCOUNTINGDOCUMENT          : abap.char(10);

  REFERENCEDOCUMENTTYPE       : abap.char(5);
  ORIGINALREFERENCEDOCUMENT   : abap.char(20);
  DOCUMENTITEMTEXT            : abap.char(500);

  BusinessTransactionType     : abap.char(4);

  Supplier                    : abap.char(10);
  Customer                    : abap.char(10);

  CostCenter                  : kostl;
  ProfitCenter                : prctr;
  FunctionalArea              : fkber;
  BusinessArea                : gsber;
  BusinessPlace               : abap.char(4);
  Segment                     : fb_segment;
  Plant                       : abap.char(4);
  ControllingArea             : abap.char(4);

  ReversalReason              : stgrd;
  IsReversal                  : abap.char(1);
  IsReversed                  : abap.char(1);
  ReversedReferenceDocument   : abap.char(10);
  ReversalReferenceDocument   : abap.char(10);
  ReversedDocument            : abap.char(10);
  ReverseDocument             : abap.char(10);

  COMPANYCODECURRENCY         : abap.cuky(5);
  DEBITCREDITCODE             : abap.char(1);
  AMOUNTINCOMPANYCODECURRENCY : abap.curr(23,2);
  CREDITAMOUNTINCMPCDCRCY     : abap.curr(23,2);
  DEBITAMOUNTINCMPCDCRCY      : abap.curr(23,2);
  RUNNINGBALANCE              : abap.curr(23,2);

}
implemented by method
  ZCL_GLACCOUNTSTATEMENT=>GET_STATEMENT;
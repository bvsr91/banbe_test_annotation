namespace ferrero.iban;

using {
    managed,
    cuid,
    Currency,
    Country,
    sap.common,
    sap.common.CodeList
} from '@sap/cds/common';

entity Request : managed {
    key RequestUUID    : UUID;
        RequestID      : Integer @readonly default 0;
        VendorUser     : String;
        VendorCode     : String;
        VendorName     : String;
        AccountHolder  : String;
        IBAN           : String;
        BIC_SWIFT_Code : String;
        RequestType    : String;
        RiskScore      : String;
        SubmissionDate : Date;
        Status         : String;
}

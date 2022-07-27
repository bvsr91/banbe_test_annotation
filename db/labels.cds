using {ferrero.iban as schema} from './data-model';

annotate schema.Request {
    RequestID      @title : '{i18n>RequestID}';
    VendorUser     @title : '{i18n>VendorUser}';
    VendorCode     @title : '{i18n>VendorCode}';
    VendorName     @title : '{i18n>VendorName}';
    AccountHolder  @title : '{i18n>AccountHolder}';
    IBAN           @title : '{i18n>IBAN}';
    BIC_SWIFT_Code @title : '{i18n>BIC_SWIFT_Code}';
    RequestType    @title : '{i18n>RequestType}';
    RiskScore      @title : '{i18n>RiskScore}';
    SubmissionDate @title : '{i18n>SubmissionDate}';
    status         @title : '{i18n>Status}';
    approver       @title : '{i18n>approver}';
    approvedDate   @title : '{i18n>approvedDate}';
}

annotate schema.Request_Attachments {
    content
             @title : '{i18n>cotent}';
    fileType @title : '{i18n>fileType}';
    fileName @title : '{i18n>fileName}';
}

annotate schema.User_Vendor {
    displayName @title : '{i18n>displayName}';
}

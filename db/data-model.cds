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
        // key RequestUUID    : UUID;
    key RequestID      : Integer;
        VendorUser     : String;
        VendorCode     : String;
        VendorName     : String;
        AccountHolder  : String;
        IBAN           : String;
        BIC_SWIFT_Code : String;
        RequestType    : String;
        RiskScore      : String;
        SubmissionDate : Date;
        approver       : String;
        approvedDate   : DateTime;
        status         : Association to statusList;
        linkToAttach   : Composition of Request_Attachments;
}

entity Request_Attachments {
    key uuid     : UUID;
        @Core.MediaType               : fileType
        // @Core.ContentDisposition.Filename : fileName
        // @Core.ContentDisposition.Filename : fileName
        @Core.ContentDisposition.Type : 'inline'
        content  : LargeBinary;
        fileType : String @Core.IsMediaType;
        fileName : String;
}

entity statusList : CodeList {
        @UI.Hidden       : true
        @UI.HiddenFilter : true
    key code                    : String enum {
            P = 'Pending';
            A = 'Approved';
            R = 'Rejected';
            D = 'Deleted';
        } default 'Pending'; //> will be used for foreign keys as well
        criticality             : Integer; //  2: yellow colour,  3: green colour, 0: unknown
        createDeleteHidden      : Boolean;
        insertDeleteRestriction : Boolean; // = NOT createDeleteHidden
}

entity Vendors {
    key VendorCode : String;
        VendorName : String;
}


entity User_Vendor {
    key User      : String;
    key VendoCode : String;
}

view User_Vendor_V as
    select
        a.User,
        a.VendoCode,
        b.VendorName
    from User_Vendor as a
    inner join Vendors as b
        on a.VendoCode = b.VendorCode
    where
        a.User = upper($user);

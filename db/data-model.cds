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
        CompanyCode    : Association to CompanyCodes @description : 'Company Code'
                                                     @Common :      {Text : 'CompanyCodes.CompanyName'};
        IBAN           : String(34);
        BIC_SWIFT_Code : String(11);
        RequestType    : String;
        RiskScore      : String;
        SubmissionDate : Date;
        approver       : String;
        approvedDate   : DateTime;
        redirect_uri   : String;
        code           : String;
        status         : Association to statusList;
        linkToAttach   : Composition of many Request_Attachments
                             on linkToAttach.p_request = $self;
}

entity Request_Attachments : managed {
    key uuid       : UUID;
        p_request  : Association to Request;
        @Core.MediaType               : fileType
        // @Core.ContentDisposition.Filename : fileName
        // @Core.ContentDisposition.Filename : fileName
        @Core.ContentDisposition.Type : 'inline'
        content    : LargeBinary;
        fileType   : String @Core.IsMediaType;
        fileName   : String;
        aprRejFlag : String(1);
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
    key User             : String;
    key VendoCode        : String;
        displayName      : String;
        user_mail        : String;
        bindauth_allowed : Boolean;
        bindClientID     : String @readonly;
        isAliasEnabled   : Boolean;
        isApprover       : Boolean;
}

entity CompanyCodes {
    key CoCd        : String(4);
        CompanyName : String;
}

view User_Vendor_V as
    select
        a.User,
        a.VendoCode,
        a.displayName,
        a.user_mail,
        a.bindauth_allowed,
        b.VendorName,
        a.bindClientID,
        a.isAliasEnabled,
        a.isApprover
    from User_Vendor as a
    inner join Vendors as b
        on a.VendoCode = b.VendorCode
    where
        lower(
            a.User
        ) = lower($user);

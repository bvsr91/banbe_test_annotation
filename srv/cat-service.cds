using {ferrero.iban as iban} from '../db/data-model';

// @requires : 'authenticated-user'
service CatalogService @(impl : './cat-service.js') @(path : '/IbanSrv') {

    @insertonly
    @Capabilities : {
        InsertRestrictions.Insertable : true,
        UpdateRestrictions.Updatable  : true,
        DeleteRestrictions.Deletable  : false
    }
    entity Request            as projection on iban.Request;

    @insertonly
    entity RequestAttachments as projection on iban.Request_Attachments;

    @readonly
    entity StatusCodeList     as projection on iban.statusList;

    @readonly
    entity User_Vendor        as projection on iban.User_Vendor;

    @readonly
    entity Vendor             as projection on iban.Vendors;

    @readonly
    view Request_U as
        select
            key RequestID,
                VendorUser,
                VendorCode,
                a.VendorName,
                b.displayName,
                AccountHolder,
                CompanyCode,
                IBAN,
                BIC_SWIFT_Code,
                RequestType,
                SubmissionDate,
                status,
                linkToAttach,
                createdAt,
                createdBy,
                a.modifiedAt
        from iban.Request as a
        inner join User_Vendor_V as b
            on  a.VendorCode = b.VendoCode
            and lower(
                a.createdBy
            )                = lower(
                b.User
            )
        where
            a.VendorCode = b.VendoCode
        order by
            a.modifiedAt desc;

    @readonly
    @(restrict : [{
        grant : 'READ',
        to    : ['ibanInternal_sc']
    }])
    view Request_A as
        select
            key RequestID,
                VendorUser,
                a.VendorCode,
                v.VendorName,
                b.displayName,
                AccountHolder,
                CompanyCode,
                IBAN,
                BIC_SWIFT_Code,
                RequestType,
                SubmissionDate,
                status,
                approver,
                approvedDate,
                linkToAttach,
                a.createdAt,
                a.createdBy,
                a.modifiedAt
        from iban.Request as a
        left outer join User_Vendor as b
            on lower(
                a.createdBy
            ) = lower(
                b.User
            )
        left outer join Vendor as v
            on a.VendorCode = v.VendorCode
        order by
            a.modifiedAt desc;

    @cds.redirection.target
    view RequestAttachments_U as
        select * from iban.Request_Attachments
        where
            lower(createdBy) = lower($user);

    @(restrict : [{
        grant : 'READ',
        to    : ['ibanInternal_sc']
    }])
    view RequestAttachments_A as
        select * from iban.Request_Attachments
        order by
            createdAt desc;

    @readonly
    entity User_Vendor_V      as projection on iban.User_Vendor_V;

    action fetchToken(code : String, redirect_uri : String, IBAN : String, AccountHolder : String, RequestType : String, BIC_SWIFT_Code : String, VendorUser : String, VendorCode : String, VendorName : String, CompanyCode_CoCd : String) returns String;
    action addAlias(code : String, redirect_uri : String, vendorCode : String)                                                                                                                                                              returns String;

    @readonly
    entity CompanyCodes       as projection on iban.CompanyCodes;


    action updateRequest(batch : LargeString)                                                                                                                                                                                               returns String;

    // type oUpdateReq : {
    //     iReq         :      Integer;
    //     sAction      :      String;
    //     aAttachments : many oAttach;
    // }

    // type oAttach : {
    //     fileName : String;
    //     fileType : String;
    //     content  : LargeBinary;
    // }
    type oAttachs : {
        iReq     : Integer;
        sAction  : String;
        fileName : String;
        fileType : String;
        content  : LargeBinary;
    }
}

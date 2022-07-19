using {ferrero.iban as iban} from '../db/data-model';

// @requires : 'authenticated-user'
service CatalogService @(impl : './cat-service.js') @(path : '/IbanSrv') {
    @insertonly
    entity Request            as projection on iban.Request;

    entity RequestAttachments as projection on iban.Request_Attachments;

    @readonly
    entity StatusCodeList     as projection on iban.statusList;

    function getUserDetails() returns String;

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
                AccountHolder,
                IBAN,
                BIC_SWIFT_Code,
                RequestType,
                SubmissionDate,
                status,
                linkToAttach,
                createdAt,
                createdBy
        from iban.Request as a
        inner join User_Vendor_V as b
            on a.VendorCode = b.VendoCode
        where
            a.VendorCode = b.VendoCode;

    entity User_Vendor_V      as projection on iban.User_Vendor_V;
}

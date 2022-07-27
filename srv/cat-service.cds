using {ferrero.iban as iban} from '../db/data-model';

// @requires : 'authenticated-user'
service CatalogService @(impl : './cat-service.js') @(path : '/IbanSrv') {
    // @insertonly  @updateonly
    entity Request @(Capabilities : {
        InsertRestrictions : {
            Insertable  : true,
            Permissions : [{Scopes : [
                {Scope : 'ibanInternal_sc'},
                {Scope : 'ibanExternal_sc'}
            ]}]
        },
        UpdateRestrictions : {Updatable : true},
        ReadRestrictions   : {Readable : false}
    }, )                  as projection on iban.Request;

    entity RequestAttachments @(restrict : [
        {
            grant : 'READ',
            to    : 'ibanInternal_sc'
        },
        {
            grant : ['*'],
            to    : 'ibanExternal_sc'
        }
    ])                    as projection on iban.Request_Attachments;

    @readonly
    entity StatusCodeList as projection on iban.statusList;

    function getUserDetails() returns String;

    @readonly
    entity User_Vendor @(restrict : [{
        grant : 'READ',
        to    : [
            'ibanExternal_sc',
            'ibanInternal_sc'
        ]
    }])                   as projection on iban.User_Vendor;

    @readonly
    entity Vendor @(restrict : [{
        grant : 'READ',
        to    : [
            'ibanExternal_sc',
            'ibanInternal_sc'
        ]
    }])                   as projection on iban.Vendors;

    @readonly
    @(restrict : [{
        grant : 'READ',
        to    : [
            'ibanExternal_sc',
            'ibanInternal_sc'
        ]
    }])
    view Request_U as
        select
            key RequestID,
                VendorUser,
                VendorCode,
                a.VendorName,
                b.displayName,
                AccountHolder,
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
            and upper(
                a.createdBy
            )                = upper(
                b.User
            )
        where
            a.VendorCode = b.VendoCode
        order by
            a.modifiedAt desc;

    @readonly
    @(restrict : [{
        grant : 'READ',
        to    : [
            'ibanExternal_sc',
            'ibanInternal_sc'
        ]
    }])
    view Request_A as
        select
            key RequestID,
                VendorUser,
                a.VendorCode,
                v.VendorName,
                b.displayName,
                AccountHolder,
                IBAN,
                BIC_SWIFT_Code,
                RequestType,
                SubmissionDate,
                status,
                approver,
                approvedDate,
                linkToAttach,
                createdAt,
                createdBy,
                a.modifiedAt
        from iban.Request as a
        left outer join User_Vendor as b
            on upper(
                a.createdBy
            ) = upper(
                b.User
            )
        left outer join Vendor as v
            on a.VendorCode = v.VendorCode
        order by
            a.modifiedAt desc;

    @(restrict : [{
        grant : 'READ',
        to    : [
            'ibanExternal_sc',
            'ibanInternal_sc'
        ]
    }])
    entity User_Vendor_V  as projection on iban.User_Vendor_V;
}

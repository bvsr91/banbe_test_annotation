using CatalogService from './cat-service';

annotate CatalogService.Request with @(UI : {
    LineItem        : [
        {
            $Type                 : 'UI.DataField',
            Value                 : RequestID,
            ![@UI.Importance]     : #High,
            ![@HTML5.CssDefaults] : {width : '9rem'}
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : RequestType,
            ![@HTML5.CssDefaults] : {width : '8rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : VendorUser,
            ![@HTML5.CssDefaults] : {width : '10rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type             : 'UI.DataField',
            Value             : VendorCode,
            ![@UI.Importance] : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : VendorName,
            ![@HTML5.CssDefaults] : {width : '7rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type             : 'UI.DataField',
            Value             : SubmissionDate,
            ![@UI.Importance] : #Low
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : status_code,
            Criticality           : status.criticality,
            ![@HTML5.CssDefaults] : {width : '7rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type             : 'UI.DataField',
            Value             : IBAN,
            ![@UI.Importance] : #High
        },
        {
            $Type             : 'UI.DataField',
            Value             : BIC_SWIFT_Code,
            ![@UI.Importance] : #High
        },
        {
            $Type             : 'UI.DataField',
            Value             : AccountHolder,
            ![@UI.Importance] : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : createdBy,
            ![@HTML5.CssDefaults] : {width : '7rem'},
            ![@UI.Importance]     : #Low
        },
        {
            $Type             : 'UI.DataField',
            Value             : modifiedAt,
            ![@UI.Importance] : #Low
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : modifiedBy,
            ![@HTML5.CssDefaults] : {width : '7rem'},
            ![@UI.Importance]     : #Low
        }
    ],
    SelectionFields : [
        RequestID,
        RequestType,
        VendorCode,
        status_code
    ],
});

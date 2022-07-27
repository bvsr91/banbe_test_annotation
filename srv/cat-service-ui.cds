using CatalogService from './cat-service';

annotate CatalogService.Request with @(UI : {
    LineItem        : [
        {
            $Type                 : 'UI.DataField',
            Value                 : RequestID,
            ![@UI.Importance]     : #High,
            ![@HTML5.CssDefaults] : {width : '8rem'}
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : RequestType,
            ![@HTML5.CssDefaults] : {width : '6rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type             : 'UI.DataField',
            Value             : IBAN,
            ![@UI.Importance] : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : BIC_SWIFT_Code,
            ![@HTML5.CssDefaults] : {width : '9rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : status_code,
            Criticality           : status.criticality,
            ![@HTML5.CssDefaults] : {width : '7rem'},
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

annotate CatalogService.Request_U with @(UI : {
    LineItem        : [
        {
            $Type                 : 'UI.DataField',
            Value                 : RequestID,
            ![@UI.Importance]     : #High,
            ![@HTML5.CssDefaults] : {width : '8rem'}
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : RequestType,
            ![@HTML5.CssDefaults] : {width : '6rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type             : 'UI.DataField',
            Value             : IBAN,
            ![@UI.Importance] : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : BIC_SWIFT_Code,
            ![@HTML5.CssDefaults] : {width : '9rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : status_code,
            Criticality           : status.criticality,
            ![@HTML5.CssDefaults] : {width : '7rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : displayName,
            ![@HTML5.CssDefaults] : {width : '10rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : VendorCode,
            ![@HTML5.CssDefaults] : {width : '7rem'},
            ![@UI.Importance]     : #High
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
            $Type             : 'UI.DataField',
            Value             : AccountHolder,
            ![@UI.Importance] : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : createdBy,
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

annotate CatalogService.Request_U {
    VendorCode @UI.HiddenFilter : true;
    VendorName @UI.HiddenFilter : true;
    createdBy  @UI.HiddenFilter : true;
};

annotate CatalogService.Request_A with @(UI : {
    LineItem        : [
        {
            $Type                 : 'UI.DataField',
            Value                 : RequestID,
            ![@UI.Importance]     : #High,
            ![@HTML5.CssDefaults] : {width : '7rem'}
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : RequestType,
            ![@HTML5.CssDefaults] : {width : '7rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type             : 'UI.DataField',
            Value             : IBAN,
            ![@UI.Importance] : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : BIC_SWIFT_Code,
            ![@HTML5.CssDefaults] : {width : '9rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : status_code,
            Criticality           : status.criticality,
            ![@HTML5.CssDefaults] : {width : '7rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : displayName,
            ![@HTML5.CssDefaults] : {width : '10rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : VendorCode,
            ![@HTML5.CssDefaults] : {width : '7rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : VendorName,
            ![@HTML5.CssDefaults] : {width : '8rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : SubmissionDate,
            ![@HTML5.CssDefaults] : {width : '8rem'},
            ![@UI.Importance]     : #Low
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
            $Type                 : 'UI.DataField',
            Value                 : approver,
            ![@HTML5.CssDefaults] : {width : '8rem'},
            ![@UI.Importance]     : #High
        },
        {
            $Type                 : 'UI.DataField',
            Value                 : approvedDate,
            ![@HTML5.CssDefaults] : {width : '9rem'},
            ![@UI.Importance]     : #High
        }
    ],
    SelectionFields : [
        RequestID,
        RequestType,
        VendorCode,
        status_code
    ],
});

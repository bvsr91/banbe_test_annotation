using {ferrero.iban as iban} from '../db/data-model';

// @requires : 'authenticated-user'
service CatalogService @(impl : './cat-service.js') @(path : '/IbanSrv') {
    entity Request            as projection on iban.Request;
    entity RequestAttachments as projection on iban.Request_Attachments;
    entity StatusCodeList     as projection on iban.statusList;
}

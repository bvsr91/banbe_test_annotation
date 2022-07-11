using {ferrero.iban as iban} from '../db/data-model';

@requires : 'authenticated-user'
service CatalogService @(path : '/IbanSrv') {
    entity Request as projection on iban.Request;
}

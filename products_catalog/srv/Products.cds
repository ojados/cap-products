using {com.logali as database} from '../db/schema';

service CatalogService {
    entity Products as projection on database.Products;
    entity Suppliers as projection on database.Suppliers;
}
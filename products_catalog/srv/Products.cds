using {com.logali as database} from '../db/schema';

service CatalogService {
    entity Products as projection on database.Products;
}
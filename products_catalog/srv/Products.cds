using {com.logali as database} from '../db/schema';

service CatalogService {
    entity Products as projection on database.Products;
    entity Suppliers as projection on database.Suppliers;
    entity Currency as projection on database.Currencies;
    entity DimensionUnit as projection on database.DimensionUnits;
    entity Category as projection on database.Categories;
    entity SalesData as projection on database.SalesData;
    entity Reviews as projection on database.ProductReviews;
    entity UnitOfMeasure as projection on database.UnitOfMeasures;
    entity Months as projection on database.Months;
    entity Order as projection on database.Orders;
    entity OrderItem as projection on database.OrderItems;
    }
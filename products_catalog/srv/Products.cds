using {com.logali as database} from '../db/schema';

service CatalogService {
    entity Products as projection on database.materials.Products;
    entity Suppliers as projection on database.sales.Suppliers;
    entity Currency as projection on database.materials.Currencies;
    entity DimensionUnit as projection on database.materials.DimensionUnits;
    entity Category as projection on database.materials.Categories;
    entity SalesData as projection on database.sales.SalesData;
    entity Reviews as projection on database.materials.ProductReviews;
    entity UnitOfMeasure as projection on database.materials.UnitOfMeasures;
    entity Months as projection on database.sales.Months;
    entity Order as projection on database.sales.Orders;
    entity OrderItem as projection on database.sales.OrderItems;
    }
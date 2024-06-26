using {com.logali as database} from '../db/schema';

// service CatalogService {
//     entity Products as projection on database.materials.Products;
//     entity Suppliers as projection on database.sales.Suppliers;
//     entity Currency as projection on database.materials.Currencies;
//     entity DimensionUnit as projection on database.materials.DimensionUnits;
//     entity Category as projection on database.materials.Categories;
//     entity SalesData as projection on database.sales.SalesData;
//     entity Reviews as projection on database.materials.ProductReviews;
//     entity UnitOfMeasure as projection on database.materials.UnitOfMeasures;
//     entity Months as projection on database.sales.Months;
//     entity Order as projection on database.sales.Orders;
//     entity OrderItem as projection on database.sales.OrderItems;
//     }

define service CatalogService {
    entity Products          as
        select from database.reports.Products {
            ID,
            Name          as ProductName     @mandatory,
            Description                      @mandatory,
            ImageUrl,
            ReleaseDate,
            DiscontinuedDate,
            Price                            @mandatory,
            Height,
            Width,
            Depth,
            Quantity                         @(
                mandatory,
                assert.range: [
                    0,
                    00,
                    20
                ]
            ),
            UnitOfMeasure as ToUnitOfMeasure @mandatory,
            Currency      as ToCurrency      @mandatory,
            Category      as ToCategory      @mandatory,
            Category.Name as Category        @readonly,
            DimensionUnit as ToDimensionUnit,
            SalesData,
            Supplier,
            Reviews,
            Rating,
            StockAvailability,
            ToStockAvailability
        };

    @readonly
    entity Supplier          as
        select from database.sales.Suppliers {
            ID,
            Name,
            Email,
            Phone,
            Fax,
            Product as ToProduct,
        };

    entity Reviews           as
        select from database.materials.ProductReviews {
            ID,
            Name,
            Rating,
            Comment,
            createdAt,
            Product as ToProduct
        };

    @readonly
    entity SalesData         as
        select from database.sales.SalesData {
            ID,
            DeliveryDate,
            Revenue,
            Currency.ID               as CurrencyKey,
            DeliveryMonth.ID          as DeliveryMonthId,
            DeliveryMonth.Description as DeliveryMonth,
            Product                   as ToProduct
        };

    @readonly
    entity StockAvailability as
        select from database.materials.StockAvailability {
            ID,
            Description,
            Product as ToProduct
        };

    @readonly
    entity VH_Categories     as
        select from database.materials.Categories {
            ID   as Code,
            Name as Text
        };

    @readonly
    entity VH_Currencies     as
        select from database.materials.Currencies {
            ID          as Code,
            Description as Text
        };

    @readonly
    entity VH_UnitOfMeasure  as
        select from database.materials.UnitOfMeasures {
            ID          as Code,
            Description as Text
        };

    @readonly
    entity VH_DimensionUnits as
        select
            ID          as Code,
            Description as Text
        from database.materials.DimensionUnits; // Proyección con Postfix: elementos antes
}

define service MyService {

    entity SuppliersProduct  as
        select from database.materials.Products[Name = 'Bread']{
            *,
            Name,
            Description,
            Supplier.Address
        }
        where
            Supplier.Address.PostalCode = 98074;

    entity SuppliersToSales  as
        select
            Supplier.Email,
            Category.Name,
            SalesData.Currency.ID,
            SalesData.Currency.Description
        from database.materials.Products;

    entity EntityInfix       as
        select Supplier[Name = 'Exotic Liquids'].Phone from database.materials.Products
        where
            Products.Name = 'Bread';

    entity EntityJoin        as
        select Phone from database.materials.Products
        left join database.sales.Suppliers as supp
            on(
                supp.ID = Products.Supplier.ID
            )
            and supp.Name = 'Exotic Liquids'
        where
            Products.Name = 'Bread';
}

define service Reports {
    entity AverageRating     as projection on database.reports.AverageRating;
    entity EntityCasting as select
        cast(Price as Integer) as Price,
        Price as Price2 : Integer
    from database.materials.Products;

    entity EntityExists as select from database.materials.Products {
        Name
    } where exists Supplier[Name = 'Exotic Liquids'];
}

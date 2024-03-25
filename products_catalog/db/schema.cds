namespace com.logali;

using {
    cuid,
    managed
} from '@sap/cds/common';

type Name : String(50);

type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

entity Customers : cuid {
    name : String;
};

type Dec  : Decimal(16, 2);

context materials {
    entity Products : cuid, managed {
        Name             : localized Name not null; // default 'NoName';
        Description      : localized String;
        ImageUrl         : String;
        //        Category         : String;
        ReleaseDate      : DateTime default $now;
        //        CreationDate     : Date default CURRENT_DATE;
        DiscontinuedDate : DateTime;
        Price            : Dec;
        Height           : type of Price; //Decimal(16, 2);
        Width            : Decimal(16, 2);
        Depth            : Decimal(16, 2);
        Quantity         : Decimal(16, 2);
        // // Association unmanaged
        // Supplier_Id      : UUID;
        // ToSupplier       : Association to one Suppliers
        //                        on ToSupplier.ID = Supplier_Id;
        // UnitOfMeasure_Id : String(2);
        // ToUnitOfMeasure  : Association to one UnitOfMeasures
        //                        on ToUnitOfMeasure.ID = UnitOfMeasure_Id;
        // Association managed
        Supplier         : Association to sales.Suppliers;
        UnitOfMeasure    : Association to UnitOfMeasures;
        Currency         : Association to Currencies;
        DimensionUnit    : Association to DimensionUnits;
        Category         : Association to Categories;
        SalesData        : Association to many sales.SalesData
                               on SalesData.Product = $self;
        Reviews          : Association to many ProductReviews
                               on Reviews.Product = $self;
    };

    entity Categories {
        key ID   : String(1);
            Name : localized Name;

    };

    entity StockAvailability {
        key ID          : Integer;
            Description : localized String;
            Product     : Association to Products;
    };

    entity Currencies {
        key ID          : String(3);
            Description : localized String;

    };

    entity UnitOfMeasures {
        key ID          : String(2);
            Description : String;
    };

    entity DimensionUnits {
        key ID          : String(2);
            Description : localized String;
    };

    entity SelProducts   as select from Products;

    entity SelProducts1  as
        select from Products {
            *
        };

    entity SelProducts2  as
        select from Products {
            Name,
            Price,
            Quantity
        };

    entity SelProducts3  as
        select from Products
        left join ProductReviews
            on Products.Name = ProductReviews.Name
        {
            Rating,
            Products.Name,
            sum(Price) as TotalPrice

        }
        group by
            Rating,
            Products.Name
        order by
            Rating;

    entity ProjProducts  as projection on Products;

    entity ProjProducts2 as
        projection on Products {
            *
        };

    entity ProjProducts3 as
        projection on Products {
            ReleaseDate,
            Name
        };

    extend Products with {
        PriceCondition     : String(2);
        PriceDetermination : String(3);
    };

    entity ProductReviews : cuid, managed {
        //    key ID           : UUID;
        //        ToProduct_Id : UUID;
        Name    : Name;
        Rating  : Integer;
        Comment : String;
        Product : Association to Products; // Association managed
    };

}

context sales {
    entity Suppliers : cuid, managed {
        Name    : type of materials.Products : Name; //Products:Name;
        Address : Address;
        Email   : String;
        Phone   : String;
        Fax     : String;
        Product : Association to many materials.Products
                      on Product.Supplier = $self;
    };


    entity Months {
        key ID               : String(2);
            Description      : localized String;
            ShortDescription : localized String(3);
    };

    entity SalesData : cuid, managed {
        //    key ID            : UUID;
        DeliveryDate  : DateTime;
        Revenue       : Decimal(16, 2);
        Product       : Association to materials.Products;
        Currency      : Association to materials.Currencies;
        DeliveryMonth : Association to Months;

    };

    entity Orders : cuid {
        Date     : Date;
        Customer : Association to Customers;
        Item     : Composition of many OrderItems
                       on Item.Order = $self;
    };

    entity OrderItems : cuid {
        Order    : Association to Orders;
        Product  : Association to materials.Products;
        Quantity : Integer;

    }

}

context reports {

    entity AverageRating as
        select from materials.ProductReviews {
            Product.ID  as ProductID,
            avg(Rating) as AverageRating : Decimal(16, 2)
        }
        group by
            Product.ID;

    entity Products      as
        select from materials.Products
        mixin {
            ToStockAvailability : Association to materials.StockAvailability
                                      on ToStockAvailability.ID = $projection.StockAvailability;
            ToAverageRating     : Association to AverageRating
                                      on ToAverageRating.ProductID = ID;
        }
        into {
            *,
            ToAverageRating.AverageRating as Rating,
            case
                when
                    Quantity >= 8
                then
                    3
                when
                    Quantity > 0
                then
                    2
                else
                    1
            end                           as StockAvailability : Integer,
            ToStockAvailability
        }
}

namespace com.logali;

type Name : String(50);

type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

// type EmailsAddresses_01: array of {
//     kind: String;
//     email: String;
// };

// type EmailsAddresses_02: {
//     kind: String;
//     email: String;
// };
// entity Emails {
//     email_01: EmailsAddresses_01;
//     email_02: many EmailsAddresses_02;
//     email_03: many {
//         kind: String;
//         email: String;
//     }
// }
entity Customers {
    key ID   : Integer;
        name : String;
};

type Dec  : Decimal(16, 2);
// type Gender: String enum {
//     male;
//     female;
// };
// entity Order {
//     clientGender: Gender;
//     status: Integer enum {
//         submitted = 1;
//         fulfilled = 2;
//         shipped = 3;
//         cancel = -1;
//     };
//     priority : String @assert.range enum{
//         high;
//         medium;
//         low;
//     }
// };

// entity Car {
//     key ID: UUID;
//     name: String;
//     virtual discount_1: Decimal;
//     @Core.Computed: false
//     virtual discount_2: Decimal;
// };
entity Products {
    key ID               : UUID;
        Name             : Name not null; // default 'NoName';
        Description      : String;
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
        Supplier         : Association to Suppliers;
        UnitOfMeasure    : Association to UnitOfMeasures;
        Currency         : Association to Currencies;
        DimensionUnit    : Association to DimensionUnits;
        Category         : Association to Categories;
        SalesData        : Association to many SalesData
                               on SalesData.Product = $self;
        Reviews          : Association to many ProductReviews
                               on Reviews.Product = $self;
};

entity Suppliers {
    key ID      : UUID;
        Name    : type of Products : Name; //Products:Name;
        Address : Address;
        Email   : String;
        Phone   : String;
        Fax     : String;
        Product : Association to many Products
                      on Product.Supplier = $self;
};


entity Categories {
    key ID   : String(1);
        Name : Name;

};

entity StockAvailability {
    key ID          : Integer;
        Description : String;
};

entity Currencies {
    key ID          : String(3);
        Description : String;

};

entity UnitOfMeasures {
    key ID          : String(2);
        Description : String;
};

entity DimensionUnits {
    key ID          : String(2);
        Description : String;
};

entity Months {
    key ID               : String(2);
        Description      : String;
        ShortDescription : String(3);
};

entity ProductReviews {
    key ID           : UUID;
        ToProduct_Id : UUID;
        CreatedAt    : DateTime;
        Name         : Name;
        Rating       : Integer;
        Comment      : String;
        Product      : Association to Products; // Association managed
};

entity SalesData {
    key ID            : UUID;
        DeliveryDate  : DateTime;
        Revenue       : Decimal(16, 2);
        Product       : Association to Products;
        Currency      : Association to Currencies;
        DeliveryMonth : Association to Months;

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

// entity ParamProducts(pName : String) as
//     select from Products {
//         Name,
//         Price,
//         Quantity
//     }
//     where
//         Name = :pName;

// entity ProjParamProducts(pName: String) as projection on Products where Name = :pName;
extend Products with {
    PriceCondition     : String(2);
    PriceDetermination : String(3);
};

// Sample showing association many to many
entity Course {
    key ID      : UUID;
        Student : Association to many StudentCourse
                      on Student.Course = $self;
};

entity Student {
    key ID     : UUID;
        Course : Association to many StudentCourse
                     on Course.Student = $self;
};

entity StudentCourse {
    key ID      : UUID;
        Student : Association to Student;
        Course  : Association to Course;


};
// Composition inline
// entity Orders_opt {
//     key ID: UUID;
//     Date: Date;
//     Customer: Association to Customers;
//     Item: Composition of many {
//         key Position: Integer;
//         Order: Association to Orders;
//         Product: Association to Products;
//         Quantity: Integer;
//     };
// };

entity Orders {
    key ID: UUID;
    Date: Date;
    Customer: Association to Customers;
    Item: Composition of many OrderItems on Item.Order = $self;
    };

entity OrderItems {
    key ID: UUID;
    Order: Association to Orders;
    Product: Association to Products;
    Quantity: Integer;
    
}

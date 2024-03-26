namespace com.training;

using {cuid} from '@sap/cds/common';

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

// entity ParamProducts(pName : String) as
//     select from Products {
//         Name,
//         Price,
//         Quantity
//     }
//     where
//         Name = :pName;

// entity ProjParamProducts(pName: String) as projection on Products where Name = :pName;

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

// Sample showing association many to many
entity Course : cuid {
    Student : Association to many StudentCourse
                  on Student.Course = $self;
};

entity Student : cuid {
    Course : Association to many StudentCourse
                 on Course.Student = $self;
};

entity StudentCourse : cuid {
    Student : Association to Student;
    Course  : Association to Course;


};

entity Orders {
    key ClientEmail : String(65) @odata.Type:'Edm.String';
        FirstName   : String(30);
        LastName    : String(30);
        CreatedOn   : Date;
        Reviewed    : Boolean;
        Approved    : Boolean;
}

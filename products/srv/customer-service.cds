using { com.scoolbay as scoolbay } from '../db/schema';

service CustomerService{
    entity CustomerSrv as projection on scoolbay.Customer;
}
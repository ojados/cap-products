using { sapbackend as external } from './external/sapbackend';
@graphql
define service SAPBackendExit{
   @cds.persistence : {
      table,
      skip: false
   }
   @cds.autoexpose
   //   entity Incidents as select from external.IncidentsSet;
    //     IncidenceId,
    //     EmployeeId,
    //     '' as NewProperty  <<<<<<<<<<<<<<<< new fields can be added
 //    };
      entity Incidents as projection on external.IncidentsSet;
}

@protocol: 'rest'
service RestService {
   entity Incidents as projection on SAPBackendExit.Incidents;
}

// To use swagger >> https://port4004-workspaces-ws-nfw6k.us10.trial.applicationstudio.cloud.sap/$api-docs/odata/v4/manage-orders/
// localhost+/$api-docs/+service path
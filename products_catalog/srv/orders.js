const cds = require("@sap/cds");
const { Orders } = cds.entities("com.training");

module.exports = (srv) => {

    srv.before("*", async (req) => {
        console.log(`Method: ${req.method}`);
        console.log(`Target: ${req.target}`);
    })
    /********READ OPERATION */
    srv.on("READ", "Orders", async (req) => {
        if (req.data.ClientEmail !== undefined) {
            return await SELECT.from`com.training.Orders`.where`ClientEmail = ${req.data.ClientEmail}`;
        }
        return await SELECT.from(Orders);
    });
    /** */
    srv.after("READ", "Orders", (data) => {
        data.map((order) => (order.Reviewed = true))
    });

    /********CREATE OPERATION */
    srv.on("CREATE", "Orders", async (req) => {
        let returnData = await cds.transaction(req)
            .run(
                INSERT.into(Orders).entries({
                    ClientEmail: req.data.ClientEmail,
                    FirstName: req.data.FirstName,
                    LastName: req.data.LastName,
                    CreatedOn: req.data.CreatedOn,
                    Reviewed: req.data.Reviewed,
                    Approved: req.data.Approved,
                })
            ).then((resolve, reject) => {
                console.log("Resolve", resolve);
                console.log("Reject", reject);
                if (typeof resolve !== "undefined") {
                    return req.data;
                } else {
                    req.error(409, "Record Not Inserted");
                }
            })
            .catch((err) => {
                console.log(err);
                req.error(err.code, err.message);
            });
        return returnData;
    });

    srv.before("CREATE", "Orders", (req) => {
        req.data.CreatedOn = new Date().toISOString().slice(0,10);
        req.data.Approved = false;
        req.data.Reviewed = false;
        return req;
    });

  /********UPDATE OPERATION */   
  srv.on("UPDATE", "Orders", async(req) => {
    let returnData = await cds.transaction(req).run(
    [
        UPDATE(Orders, req.data.ClientEmail).set({
            FirstName: req.data.FirstName,
            LastName: req.data.LastName
        })
    ] )
    .then((resolve, reject) => {
        console.log("Resolve: ", resolve);
        console.log("Reject: ", reject);

        if (resolve[0] == 0) {
            req.error(409, "Record not found");
        }
    }).
    
    catch((err) => {
        console.log(err);
        req.error(err.code, err.message);
    });
    console.log("Before End", returnData);
    return returnData;
  }) 

 /********DELETE OPERATION */    
 srv.on("DELETE", "Orders", async(req) => {
    let returnData = await cds.transaction(req).run(
    DELETE.from(Orders).where({ClientEmail: req.data.ClientEmail})
        )
    .then((resolve, reject) => {
        console.log("Resolve: ", resolve);
        console.log("Reject: ", reject);

        if (resolve !== 1) {
            req.error(409, "Record not found");
        }
    }).
    
    catch((err) => {
        console.log(err);
        req.error(err.code, err.message);
    });
    console.log("Before End", returnData);
    return await returnData;
  });

 /********FUNCTION */  
  srv.on("getClientTaxRate", async (req) => {
// NO server side-effect
    const {ClientEmail} = req.data;
    const db = srv.transaction(req);

    const results = await db.read(Orders, ["Country_code"]).where({ClientEmail: ClientEmail});

    console.log(results[0]);

    switch (results[0].Country_code){
        case 'ES':
            return 21.5;
            break;
        case 'UK':
            return 24.6;
            break;
        default:
            break;
    }
  });
 /********ACTION */  
  srv.on("cancelOrder", async (req) => {
    const{clientEmail} = req.data;
    const db = srv.transaction(req);

    const resultsRead = await db.read(Orders, ["FirstName", "LastName", "Approved"]).where({ClientEmail: clientEmail});

    let returnOrder = {
        status : "",
        message : ""
    };

    if (resultsRead[0].Approved == false) {
        const resultsUpdate = await db.update(Orders).set({Status: 'C'}).where({ClientEmail: clientEmail});
        returnOrder.status = "Succeeded";
        returnOrder.message = `The Order placed by ${resultsRead[0].FirstName} ${resultsRead[0].LastName} was cancel`;
    } else {
        returnOrder.status = "Failed";
        returnOrder.message = `The Order placed by ${resultsRead[0].FirstName} ${resultsRead[0].LastName} was NOT cancel`;
    }
    console.log("Action cancelOrder executed");
    return returnOrder;
  });
};
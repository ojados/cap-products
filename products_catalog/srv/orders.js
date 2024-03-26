const cds = require("@sap/cds");
const { Orders } = cds.entities("com.training");

module.exports = (srv) => {
    /********READ OPERATION */
    srv.on("READ", "GetOrders", async (req) => {
        if (req.data.ClientEmail !== undefined) {
            return await SELECT.from`com.training.Orders`.where`ClientEmail = ${req.data.ClientEmail}`;
        }
        return await SELECT.from(Orders);
    });
    /** */
    srv.after("READ", "GetOrders", (data) => {
        data.map((order) => (order.Reviewed = true))
    });

    /********CREATE OPERATION */
    srv.on("CREATE", "CreateOrder", async (req) => {
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

    srv.before("CREATE", "CreateOrder", (req) => {
        req.data.CreatedOn = new Date().toISOString().slice(0,10);
        req.data.Approved = false;
        req.data.Reviewed = false;
        return req;
    });

  /********UPDATE OPERATION */   
  srv.on("UPDATE", "UpdateOrder", async(req) => {
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
};
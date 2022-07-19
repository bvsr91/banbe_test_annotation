const cds = require('@sap/cds');

module.exports = async function () {
    const db = await cds.connect.to('db')
    const {
        Request,
        Request_Attachments,
        User_Vendor_V
    } = db.entities("ferrero.iban");
    this.before("INSERT", "RequestAttachments", async (req, next) => {
        try {
            const buf = Buffer.from(req.data.content, 'base64');
            req.data.content = buf;
            req.data.uuid = cds.utils.uuid();
        } catch (error) {
            req.reject(400, error);
        }
    });
    this.before("INSERT", "Request", async (req, next) => {
        try {
            const { maxID } = await SELECT.one`max(RequestID) as maxID`.from(Request);
            req.data.RequestID = maxID + 1;
            // var oUserInfo = await SELECT.one("User_Vendor_V").where({ User: req.user.id });
            // if (oUserInfo) {
            //     req.data.VendorUser = req.data.id;
            //     req.data.VendorCode = oUserInfo.VendoCode;
            //     req.data.VendorName = oUserInfo.VendorName;
            // } else {
            //     req.reject(400, "No Vendor code maintained for the user");
            // }
            req.data.SubmissionDate = new Date().toISOString();
            if (req.data.linkToAttach) {
                const buf = Buffer.from(req.data.linkToAttach.content, 'base64');
                req.data.linkToAttach.content = buf;
            }
            req.data.uuid = cds.utils.uuid();
        } catch (error) {
            req.reject(400, error);
        }
    });
    this.on("getUserDetails", async (req) => {
        return req.user.id;
    });

}
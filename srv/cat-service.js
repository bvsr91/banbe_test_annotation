const cds = require('@sap/cds');

module.exports = async function () {
    const db = await cds.connect.to('db')
    const {
        Request,
        Request_Attachments
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
            const { maxID } = await SELECT.one`max(RequestID) as maxID`.from(Request)
            req.data.RequestID = maxID + 1;
            if (req.data.linkToAttach) {
                const buf = Buffer.from(req.data.linkToAttach.content, 'base64');
                req.data.linkToAttach.content = buf;
            }
            req.data.uuid = cds.utils.uuid();
        } catch (error) {
            req.reject(400, error);
        }
    });
}
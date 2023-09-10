const cds = require('@sap/cds');
const axios = require('axios');
const CircularJSON = require('circular-json');
const jwt_decode = require('jwt-decode');
const xsenv = require('@sap/xsenv');
const crypto = require('crypto');
const SapCfMailer = require('sap-cf-mailer').default;


module.exports = async function () {
    const db = await cds.connect.to('db')
    const {
        Request,
        Request_Attachments,
        User_Vendor_V,
        User_Vendor
    } = db.entities("ferrero.iban");
    this.before("INSERT", "RequestAttachments", async (req, next) => {
        try {
            if (req.data.aprRejFlag && req.data.aprRejFlag === "A" || req.data.aprRejFlag === "R") {
                var status;
                if (req.data.aprRejFlag === "A") {
                    status = "Approve";
                } else {
                    status = "Reject";
                }
                oRequest = await SELECT.one(Request).where(
                    {
                        RequestID: req.data.p_request_RequestID
                    }
                );
                if (oRequest && oRequest.status_code !== "Pending") {
                    req.error(400, "You can not " + status + " the request which is in the " + oRequest.status_code + " Status");
                }
            }
            req.data.createdBy = req.user.id.toUpperCase();
            req.data.modifiedBy = req.user.id.toUpperCase();
            const buf = Buffer.from(req.data.content, 'base64');
            req.data.content = buf;
        } catch (error) {
            req.reject(400, error);
        }
    });
    this.after("INSERT", "RequestAttachments", async (req, next) => {
        try {
            if (req.aprRejFlag && req.aprRejFlag === "A" || req.aprRejFlag === "R") {
                var status;
                if (req.aprRejFlag === "A") {
                    status = "Approved";
                } else {
                    status = "Rejected";
                }
                await UPDATE(Request).with({
                    status_code: status,
                    approvedDate: new Date().toISOString(),
                    approver: req.createdBy,
                    modifiedBy: req.createdBy
                }).where(
                    {
                        RequestID: req.p_request_RequestID
                    }
                );
            }
        } catch (error) {
            req.reject(400, error);
        }
    });
    this.before("UPDATE", "Request", async (req, next) => {
        try {
            req.data.approver = req.user.id.toUpperCase();
            req.data.modifiedBy = req.user.id.toUpperCase();

        } catch (error) {
            req.reject(400, error);
        }
    });
    this.before("INSERT", "Request", async (req, next) => {
        try {
            var sUser = req.user.id.toUpperCase();
            var oUserInfo = await SELECT.one(User_Vendor).where`upper(User)=${sUser}`;
            if (oUserInfo === null) {
                req.reject(400, "User is not maintained in the table to create request");
            }
            if (oUserInfo.bindauth_allowed !== true) {
                req.error(400, "You don't have authorization for BindID. Please contact your administrator");
            }
            if (oUserInfo.isAliasEnabled !== true) {7
                req.error(400, "Alias is not enabled for the users. Please contact your administrator");
            }

            const params = new URLSearchParams();
            var host, client_id, client_secret;
            if (process.env.NODE_ENV === "development") {
                if (JSON.parse(process.env.VCAP_SERVICES).bindId) {
                    var aBind = JSON.parse(process.env.VCAP_SERVICES).bindId;
                    host = aBind[0].url;
                    client_id = aBind[0].client_id;
                    client_secret = aBind[0].client_secret;
                } else {
                    req.rej(400, "Please maintain Bindid details locally");
                }
            } else {
                if (process.env.bindid) {
                    var oBindID = JSON.parse(process.env.bindid);
                    host = oBindID.url;
                    client_id = oBindID.client_id;
                    client_secret = oBindID.client_secret;
                } else {
                    req.reject(400, "Please maintain the BindID client details");
                }
            }
            params.append('grant_type', "authorization_code");
            params.append('code', req.data.code);
            params.append('redirect_uri', req.data.redirect_uri);
            params.append('client_id', client_id);
            params.append('client_secret', client_secret);
            try {
                var tokenResponse = await axios({
                    method: 'post',
                    url: host + 'token',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                        // ,
                        // 'Accept-Encoding': 'gzip, deflate, br'
                    },
                    data: params
                });
                var resJwks = await axios({
                    method: 'get',
                    url: host + 'jwks',
                    headers: {
                        'Content-Type': 'application/json',
                        'Cache-Control': 'no-store, must-revalidate',
                        'Pragma': 'no-cache'
                    }
                });
                try {
                    var decodedData = jwt_decode(tokenResponse.data.id_token);
                    if (decodedData.email.toUpperCase() !== oUserInfo.user_mail.toUpperCase()) {
                        req.error(400, "Invalid authorization request, email validation failed during openid authentication");
                    }
                    if (decodedData.bindid_approval.display_data.attributes) {
                        if (decodedData.bindid_approval.display_data.attributes[1].value !== req.data.IBAN) {
                            req.error(400, "Requested IBAN and authorized IBAN are different");
                        }
                    }
                    if (decodedData.exp) {
                        if (decodedData.exp < Math.round(new Date().getTime() / 1000)) {
                            req.error(400, "Token expired, please create the Request again");
                        }
                    }

                } catch (error) {
                    req.error(400, error);
                }
            } catch (error) {
                req.error(400, error);
            }
            req.data.createdBy = sUser;
            req.data.modifiedBy = sUser;
            req.data.redirect_uri = null;
            req.data.code = null;
            const { maxID } = await SELECT.one`max(RequestID) as maxID`.from(Request);
            req.data.RequestID = maxID + 1;
            req.data.SubmissionDate = new Date().toISOString();
            if (req.data.linkToAttach) {
                for (var a of req.data.linkToAttach) {
                    const buf = Buffer.from(a.content, 'base64');
                    a.content = buf;
                    a.createdBy = sUser;
                    a.modifiedBy = sUser;
                }
            }
        } catch (error) {
            req.reject(400, error);
        }
    });

    this.on("fetchToken", async (req, res) => {
        const params = new URLSearchParams();
        var host, client_id, client_secret;
        if (process.env.NODE_ENV === "development") {
            if (JSON.parse(process.env.VCAP_SERVICES).bindId) {
                var aBind = JSON.parse(process.env.VCAP_SERVICES).bindId;
                host = aBind[0].url;
                client_id = aBind[0].client_id;
                client_secret = aBind[0].client_secret;
            } else {
                req.rej(400, "Please maintain Bindid details locally");
            }
        } else {
            if (process.env.bindid) {
                var oBindID = JSON.parse(process.env.bindid);
                host = oBindID.url;
                client_id = oBindID.client_id;
                client_secret = oBindID.client_secret;
            } else {
                req.reject(400, "Please maintain the BindID client details");
            }
        }
        params.append('grant_type', "authorization_code");
        params.append('code', req.data.code);
        params.append('redirect_uri', req.data.redirect_uri);
        params.append('client_id', client_id);
        params.append('client_secret', client_secret);
        try {
            var sUser = req.user.id.toUpperCase();
            // var oUserInfo = await SELECT.one(User_Vendor).where({ func: 'toupper', args: [{ ref: ["User"] }] }, 'like', { val: `%${sUser}%` });
            var oUserInfo = await SELECT.one(User_Vendor).where`upper(User)=${sUser}`;
            if (oUserInfo === null) {
                req.reject(400, "User is not maintained in the table to create request");
            }
            if (oUserInfo.bindauth_allowed !== true) {
                req.reject(400, "You don't have authorization for BindID. Please contact your administrator");
            }
            var tokenResponse = await axios({
                method: 'post',
                url: host + 'token',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                    // ,
                    // 'Accept-Encoding': 'gzip, deflate, br'
                },
                data: params
            });
            var resJwks = await axios({
                method: 'get',
                url: host + 'jwks',
                headers: {
                    'Content-Type': 'application/json',
                    'Cache-Control': 'no-store, must-revalidate',
                    'Pragma': 'no-cache'
                }
            });
            try {
                var decodedData = jwt_decode(tokenResponse.data.id_token);
                if (decodedData.email.toUpperCase() !== oUserInfo.user_mail.toUpperCase()) {
                    req.reject(400, "Invalid authorization request, email validation failed during openid authentication");
                }
                if (decodedData.bindid_approval.display_data.attributes) {
                    if (decodedData.bindid_approval.display_data.attributes[1].value !== req.data.IBAN) {
                        req.reject(400, "Requested IBAN and authorized IBAN are different");
                    }
                }
                if (decodedData.exp) {
                    if (decodedData.exp < Math.round(new Date().getTime() / 1000)) {
                        req.reject(400, "Token expired, please create the Request again");
                    }
                }
                var oPayLoad = {

                };
                oPayLoad.createdBy = req.user.id.toUpperCase();
                oPayLoad.modifiedBy = req.user.id.toUpperCase();
                const { maxID } = await SELECT.one`max(RequestID) as maxID`.from(Request);
                oPayLoad.RequestID = maxID + 1;
                if (req.data.AccountHolder && req.data.AccountHolder !== "undefined") {
                    oPayLoad.AccountHolder = req.data.AccountHolder;
                }
                if (req.data.CompanyCode_CoCd && req.data.CompanyCode_CoCd !== "undefined") {
                    oPayLoad.CompanyCode_CoCd = req.data.CompanyCode_CoCd;
                }
                if (req.data.IBAN && req.data.IBAN !== "undefined") {
                    oPayLoad.IBAN = req.data.IBAN;
                }
                if (req.data.RequestType && req.data.RequestType !== "undefined") {
                    oPayLoad.RequestType = req.data.RequestType;
                }
                if (req.data.BIC_SWIFT_Code && req.data.BIC_SWIFT_Code !== "undefined") {
                    oPayLoad.BIC_SWIFT_Code = req.data.BIC_SWIFT_Code;
                }
                if (req.data.VendorUser && req.data.VendorUser !== "undefined") {
                    oPayLoad.VendorUser = req.data.VendorUser;
                }
                if (req.data.VendorCode && req.data.VendorCode !== "undefined") {
                    oPayLoad.VendorCode = req.data.VendorCode;
                }
                if (req.data.VendorName && req.data.VendorName !== "undefined") {
                    oPayLoad.VendorName = req.data.VendorName;
                }
                oPayLoad.SubmissionDate = new Date().toISOString();

                var oRes = await INSERT.into(Request).entries(oPayLoad);
                // const mailer = new SapCfMailer("SendMail_Eos");
                // const mailer = new SapCfMailer("SendMail");
                // const result = await mailer.sendMail({
                //     // to: 'b.b.srinivasa.reddy@accenture.com',
                //     to: 'SrinivasaReddy.BUTUKURI@guest.ferrero.com',
                //     subject: "This is the mail subject",
                //     text: "body of the email"
                // });
                return oPayLoad.RequestID.toString();
            } catch (error) {
                req.reject(400, error);
            }
        } catch (error) {
            req.reject(400, error);
        }
    });

    this.after("READ", "User_Vendor_V", async (req, res) => {
        if (process.env.bindid) {
            var oBindID = JSON.parse(process.env.bindid);
            if (req.length > 0) {
                req[0].bindClientID = oBindID.client_id;
            }
        } else {
            if (req.length > 0) {
                req[0].bindClientID = "";
            }
        }
        return req;
    });

    this.on("addAlias", async (req, res) => {
        const params = new URLSearchParams();
        var host, client_id, client_secret, session_uri;
        if (process.env.NODE_ENV === "development") {
            if (JSON.parse(process.env.VCAP_SERVICES).bindId) {
                var aBind = JSON.parse(process.env.VCAP_SERVICES).bindId;
                host = aBind[0].url;
                client_id = aBind[0].client_id;
                client_secret = aBind[0].client_secret;
                session_uri = aBind[0].session_uri;
            } else {
                req.rej(400, "Please maintain Bindid details locally");
            }
        } else {
            if (process.env.bindid) {
                var oBindID = JSON.parse(process.env.bindid);
                host = oBindID.url;
                client_id = oBindID.client_id;
                client_secret = oBindID.client_secret;
                session_uri = oBindID.session_uri;
            } else {
                req.reject(400, "Please maintain the BindID client details");
            }
        }
        params.append('grant_type', "authorization_code");
        params.append('code', req.data.code);
        params.append('redirect_uri', req.data.redirect_uri);
        params.append('client_id', client_id);
        params.append('client_secret', client_secret);
        try {
            var sUser = req.user.id.toUpperCase();
            var oUserInfo = await SELECT.one(User_Vendor).where`upper(User)=${sUser}`;
            if (oUserInfo === null) {
                req.reject(400, "User is not maintained in the table to create request");
            }
            if (oUserInfo.bindauth_allowed !== true) {
                req.reject(400, "You don't have authorization for BindID. Please contact your administrator");
            }
            var tokenResponse = await axios({
                method: 'post',
                url: host + 'token',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                    // ,
                    // 'Accept-Encoding': 'gzip, deflate, br'
                },
                data: params
            });
            var resJwks = await axios({
                method: 'get',
                url: host + 'jwks',
                headers: {
                    'Content-Type': 'application/json',
                    'Cache-Control': 'no-store, must-revalidate',
                    'Pragma': 'no-cache'
                }
            });
            try {
                var decodedData = jwt_decode(tokenResponse.data.id_token);
                if (decodedData.email.toUpperCase() !== oUserInfo.user_mail.toUpperCase()) {
                    req.reject(400, "Invalid authorization request, email validation failed during openid authentication");
                }
                if (decodedData.exp) {
                    if (decodedData.exp < Math.round(new Date().getTime() / 1000)) {
                        req.reject(400, "Token expired, please create the Request again");
                    }
                }
                var access_token = tokenResponse.data.access_token;
                var authvalue = crypto.createHmac('sha256', client_secret).update(access_token).digest('base64');
                var sAuthorization = "BindIdBackend AccessToken " + access_token + "; " +
                    authvalue;
                var oData = {
                    "subject_session_at": access_token,
                    "reports": [
                        {
                            "alias": req.user.id.toUpperCase(),
                            "time": Math.round(new Date().getTime() / 1000),
                            "type": "authentication_performed"
                        }
                    ]
                };
                var oSessionFeedBack = await axios({
                    method: 'post',
                    url: session_uri + 'session-feedback',
                    headers: {
                        'Content-Type': 'application/json',
                        // 'Accept-Encoding': 'gzip, deflate, br'
                        "Authorization": sAuthorization
                    },
                    data: oData
                });
                if (oSessionFeedBack.status === 200) {
                    // await UPDATE(User_Vendor).with({
                    //     isAliasEnabled: true
                    // }).where(
                    //     {
                    //         User: sUser,
                    //         VendoCode: req.data.vendorCode
                    //     }
                    // );
                    await UPDATE(User_Vendor).with({
                        isAliasEnabled: true
                    }).where`upper(User)=${sUser} and VendoCode=${req.data.vendorCode}`;
                    return "Alias added successfully";
                } else {
                    req.reject(400, "Failed to add alias, please try again");
                }
            } catch (error) {
                req.reject(400, error);
            }
        } catch (error) {
            req.reject(400, error);
        }
    });
    this.on("updateRequest", async (req, next) => {
        var oPayLoad = await next();
        try {
            var oReqData = JSON.parse(req.data.batch);
            // var oReqData = req.data.batch;
            var sUser = req.user.id.toUpperCase(),
                bApprFlag = true,
                status;
            if (oReqData.sAction && oReqData.sAction === "A" || oReqData.sAction === "R") {
                if (oReqData.sAction === "A") {
                    status = "Approved";
                } else {
                    status = "Rejected";
                }
            } else {
                req.reject(400, "Invalid action code");
            }
            var oUserInfo = await SELECT.one(User_Vendor).where`upper(User)=${sUser} and isApprover=${bApprFlag}`;
            if (oUserInfo === null) {
                req.reject(400, "You are not authorized to approve/reject this request");
            }
            if (!oReqData.iReq) {
                req.reject(400, "Invalid Request, please pass the request id in the payload");
            }
            var oReq = await SELECT.one(Request).where({ RequestID: parseInt(oReqData.iReq) });
            if (oReq === null) {
                req.reject(400, "Invalid Request, please check");
            }
            if (oReq.status_code !== "Pending") {
                req.reject(400, "You cannot approve/reject the request which is already " + oReq.status_code);
            }

            if (!oReqData.aAttachments) {
                req.reject(400, "Please add atleast one attachment");
            }
            var aAttachments = oReqData.aAttachments;
            // var aAttachments = oReqData;
            var aFinalAttach = [];
            if (aAttachments.length > 0) {
                for (var a of aAttachments) {
                    var oAttach = {};
                    if (a.content !== "" && a.content) {
                        const buf = Buffer.from(a.content, 'base64');
                        oAttach.fileName = a.fileName;
                        oAttach.fileType = a.fileType;
                        oAttach.content = buf;
                        oAttach.p_request_RequestID = parseInt(oReqData.iReq);
                        oAttach.createdBy = sUser;
                        oAttach.modifiedBy = sUser;
                        delete a.iReq;
                        delete a.sAction;
                        oAttach.uuid = cds.utils.uuid();
                        aFinalAttach.push(oAttach);
                    }
                }
                if (aFinalAttach.length > 0) {
                    var iCount = await cds.run(INSERT.into(Request_Attachments).entries(aFinalAttach));
                    await UPDATE(Request).with({
                        status_code: status,
                        approvedDate: new Date().toISOString(),
                        approver: sUser,
                        modifiedBy: sUser
                    }).where(
                        {
                            RequestID: oReqData.iReq
                        }
                    );
                }
            } else {
                req.reject(400, "Please add atleast one attachment");
            }

        } catch (error) {
            req.reject(400, error.toString());
        }
        return "Success";
    });
}

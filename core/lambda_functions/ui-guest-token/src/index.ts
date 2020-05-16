import { CloudFrontResponseHandler } from "./aws-types";
import jsdom from "jsdom";

const handler: CloudFrontResponseHandler = async event => {
    let { response, request } = event.Records[0].cf;

    let { body } = response;

    if (body && body.includes('<title>COVID Tracker Philippines</title>')) {
        var dom = new jsdom.JSDOM(body);
        let q = dom.window.document.querySelector('head');
        q.append(`WASUP: ${request.clientIp}`);
        response.body = dom.serialize();
    }
    return response;
};

export { handler };
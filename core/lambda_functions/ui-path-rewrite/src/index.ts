import URI from "urijs";
import { CloudFrontRequestHandler } from "aws-lambda";

const handler: CloudFrontRequestHandler = async event => {
    const request = event.Records[0].cf.request;
    const requestPath = URI(request.uri);

    if (requestPath.suffix()) {
        /**
         * Pass through requests with extensions (e.g. '/bar/baz.js').
         */
        return request;
    } else {
        /**
         * Rewrite extension-less requests (e.g. '/user/profile') to the first-level
         * app's index.html (e.g. '/index.html').
         */
        request.uri = `/index.html`;
        return request;
    }
};

export { handler };
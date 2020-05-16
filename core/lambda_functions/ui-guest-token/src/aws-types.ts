export type CloudFrontResponseHandler = Handler<CloudFrontResponseEvent, CloudFrontResponseResult>;
export type CloudFrontResponseCallback = Callback<CloudFrontResponseResult>;

/**
 * CloudFront viewer response or origin response event
 *
 * https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-event-structure.html#lambda-event-structure-response
 */
export interface CloudFrontResponseEvent {
    Records: Array<{
        cf: CloudFrontEvent & {
            readonly request: CloudFrontRequest;
            response: CloudFrontResponse;
        };
    }>;
}

export type CloudFrontResponseResult = undefined | null | CloudFrontResultResponse;


/**
 * CloudFront events
 * http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-event-structure.html
 * Bear in mind that the "example" event structure in the page above includes
 * both an S3 and a Custom origin, which is not strictly allowed. Only one
 * of these per event may be present.
 */
export interface CloudFrontHeaders {
    [name: string]: Array<{
        key?: string;
        value: string;
    }>;
}

export type CloudFrontOrigin =
    | { s3: CloudFrontS3Origin; custom?: never }
    | { custom: CloudFrontCustomOrigin; s3?: never };

export interface CloudFrontCustomOrigin {
    customHeaders: CloudFrontHeaders;
    domainName: string;
    keepaliveTimeout: number;
    path: string;
    port: number;
    protocol: 'http' | 'https';
    readTimeout: number;
    sslProtocols: string[];
}

export interface CloudFrontS3Origin {
    authMethod: 'origin-access-identity' | 'none';
    customHeaders: CloudFrontHeaders;
    domainName: string;
    path: string;
    region: string;
}

export interface CloudFrontResponse {
    status: string;
    statusDescription: string;
    headers: CloudFrontHeaders;
    body?: string;
}

export interface CloudFrontRequest {
    body?: {
        action: 'read-only' | 'replace';
        data: string;
        encoding: 'base64' | 'text';
        readonly inputTruncated: boolean;
    };
    readonly clientIp: string;
    readonly method: string;
    uri: string;
    querystring: string;
    headers: CloudFrontHeaders;
    origin?: CloudFrontOrigin;
}

export interface CloudFrontEvent {
    config: {
        readonly distributionDomainName: string;
        readonly distributionId: string;
        readonly eventType: 'origin-request' | 'origin-response' | 'viewer-request' | 'viewer-response';
        readonly requestId: string;
    };
}

/**
 * Generated HTTP response in viewer request event or origin request event
 *
 * https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-generating-http-responses-in-requests.html#lambda-generating-http-responses-object
 */
export interface CloudFrontResultResponse {
    status: string;
    statusDescription?: string;
    headers?: CloudFrontHeaders;
    bodyEncoding?: 'text' | 'base64';
    body?: string;
}



export type Handler<TEvent = any, TResult = any> = (
    event: TEvent,
    context: Context,
    callback: Callback<TResult>,
) => void | Promise<TResult>;

export type Callback<TResult = any> = (error?: Error | string | null, result?: TResult) => void;

export interface Context {
    callbackWaitsForEmptyEventLoop: boolean;
    functionName: string;
    functionVersion: string;
    invokedFunctionArn: string;
    memoryLimitInMB: string;
    awsRequestId: string;
    logGroupName: string;
    logStreamName: string;
    identity?: CognitoIdentity;
    clientContext?: ClientContext;

    getRemainingTimeInMillis(): number;

    // Functions for compatibility with earlier Node.js Runtime v0.10.42
    // No longer documented, so they are deprecated, but they still work
    // as of the 12.x runtime, so they are not removed from the types.

    /** @deprecated Use handler callback or promise result */
    done(error?: Error, result?: any): void;
    /** @deprecated Use handler callback with first argument or reject a promise result */
    fail(error: Error | string): void;
    /** @deprecated Use handler callback with second argument or resolve a promise result */
    succeed(messageOrObject: any): void;
    // Unclear what behavior this is supposed to have, I couldn't find any still extant reference,
    // and it behaves like the above, ignoring the object parameter.
    /** @deprecated Use handler callback or promise result */
    succeed(message: string, object: any): void;
}

export interface CognitoIdentity {
    cognitoIdentityId: string;
    cognitoIdentityPoolId: string;
}

export interface ClientContext {
    client: ClientContextClient;
    Custom?: any;
    env: ClientContextEnv;
}

export interface ClientContextClient {
    installationId: string;
    appTitle: string;
    appVersionName: string;
    appVersionCode: string;
    appPackageName: string;
}

export interface ClientContextEnv {
    platformVersion: string;
    platform: string;
    make: string;
    model: string;
    locale: string;
}

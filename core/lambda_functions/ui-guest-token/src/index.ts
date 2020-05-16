const handler: CloudFrontResponseHandler = (event, _, callback) => {
    let { response } = event.Records[0].cf;
    let { body } = response;

    if (body && body.includes('<title>COVID Tracker Philippines</title>')) {
        response.headers = {
            ...response.headers,
            was: [{key: 'wa', value: 'sap'}]   
        }
        const headEnd = body.split(' </head>');
        body = [headEnd[0], '\t\twasap broski\n\t</head>', headEnd[1]].join('\n')
        response.body = body;
    }
    //Get contents of response
    // const response = event.Records[0].cf.response;
    const headers = response.headers;
    
    console.log(JSON.stringify(headers));
    console.log(response.body);

    //Set new headers 
    headers['strict-transport-security'] = [{ key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubdomains; preload' }];
    // headers['content-security-policy'] = [{ key: 'Content-Security-Policy', value: "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'" }];
    headers['x-content-type-options'] = [{ key: 'X-Content-Type-Options', value: 'nosniff' }];
    headers['x-frame-options'] = [{ key: 'X-Frame-Options', value: 'DENY' }];
    headers['x-xss-protection'] = [{ key: 'X-XSS-Protection', value: '1; mode=block' }];
    headers['referrer-policy'] = [{ key: 'Referrer-Policy', value: 'same-origin' }];
    response.headers = headers;
    callback(null, response);
};

export { handler };
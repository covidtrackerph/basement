const handler: CloudFrontResponseHandler = async (event) => {
    let { response } = event.Records[0].cf;
    let { body } = response;

    if (body && body.includes('<title>COVID Tracker Philippines</title>')) {
        
        const headEnd = body.split(' </head>');
        body = [headEnd[0], '\t\twasap broski\n\t</head>', headEnd[1]].join('\n')
        response.body = body;
    }
    return response;
};

export { handler };
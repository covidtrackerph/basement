import { APIGatewayProxyHandler, APIGatewayProxyResult } from "aws-lambda";

const handler: APIGatewayProxyHandler = async event => {

    
    console.log(`API GATEWAY Request ID: ${event.requestContext.requestId}`)
    await sleep(1);
    const response: APIGatewayProxyResult = {
        statusCode: 200,
        body: `google-site-verification: google369e26c214f0b8a9.html`,
        headers: {
            'Content-Type': 'text/html'
        }
    }

    return response;
}

function sleep(ms: number) {
    return new Promise((res) => {
        setTimeout(() => res(), ms)
    });
}

export { handler }
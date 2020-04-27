
import { APIGatewayProxyHandler, APIGatewayProxyResult } from 'aws-lambda';
import { graphql, buildSchema } from 'graphql';
import { readFileSync } from 'fs';
import { resolver } from './resolver';
const sdl = readFileSync('./schema.graphql', 'utf8');

const schema = buildSchema(sdl);

const handler: APIGatewayProxyHandler = async (event) => {
    let result: APIGatewayProxyResult;
    try {
        const { operationName, query, variables } = JSON.parse(event.body!);
        if (typeof query === 'undefined') {
            throw new Error('Query cannot be empty');
        }
        var resp = await graphql({
            schema,
            source: query,
            operationName,
            variableValues: variables,
            rootValue: resolver
        });

        result = {
            statusCode: 200,
            body: JSON.stringify(resp),
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': '*',
                'Access-Control-Allow-Headers': '*'
            }
        }
    } catch (err) {
        result = {
            statusCode: 200,
            body: JSON.stringify(err),
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': '*',
                'Access-Control-Allow-Headers': '*'
            }
        }
    }
    return result;
}

export { handler };
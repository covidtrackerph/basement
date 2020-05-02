import * as db from './database';

enum CaseFields {
    cases,
    case,
    accumulation,
    statistics,
    ageGenderDistribution
}

const handler: Handler<AWSAppSyncEvent<keyof typeof CaseFields>, any> = async (event, _, callback) => {
    let { field, args } = event;
    try {
        switch (field) {
            case 'accumulation':
                callback(null, await db.getAccumulationAsync(args!.type));
                break;
            case 'ageGenderDistribution':
                callback(null, await db.getAgeGenderDistributionAsync(args!.type))
                break;
            case 'case':
                callback(null, await db.getByCaseNoAsync(args!.caseNo));
                break;
            case 'cases':
                callback(null, await db.getAllAsync());
                break;
            case 'statistics':
                callback(null, await db.getStatisticsAsync());
                break;
            default:
                callback(`Unknown field: ${field}`, null)
                break;
        }
    } catch (err) {
        callback(err, null);
    }
}

export { handler };
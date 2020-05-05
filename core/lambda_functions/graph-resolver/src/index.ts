import * as db from './database';

enum CaseFields {
    cases,
    case,
    accumulation,
    statistics,
    ageGenderDistribution,
    region,
    province,
    city,
    dailyStatistic
}

const handler: Handler<AWSAppSyncEvent<keyof typeof CaseFields>, any> = async (event, _, callback) => {
    let { field, args } = event;
    try {
        switch (field) {
            case 'accumulation':
                callback(null, await db.getAccumulationAsync(args!.type));
                break;
            case 'dailyStatistic':
                callback(null, await db.getDailyStatisticAsync(args!.type, args!.region || '', args!.province || '', args!.city || ''));
                break;
            case 'ageGenderDistribution':
                callback(null, await db.getAgeGenderDistributionAsync(args!.type))
                break;
            case 'case':
                callback(null, await db.getByCaseNoAsync(args!.caseNo));
                break;
            case 'cases':
                callback(null, await db.getAllAsync(args!.region || '', args!.province || '', args!.city || '', args!.offset || 0, args!.limit || 10));
                break;
            case 'statistics':
                callback(null, await db.getStatisticsAsync(args!.region || '', args!.province || '', args!.city || ''));
                break;
            case 'region':
                callback(null, await db.searchRegionsAsync(args!.query || ''))
                break;
            case 'province':
                callback(null, await db.searchProvincesAsync(args!.query || '', args!.region || ''))
                break;
            case 'city':
                callback(null, await db.searchCitiesAsync(args!.query || '', args!.province || '', args!.region || ''))
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
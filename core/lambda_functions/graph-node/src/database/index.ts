import { Client } from 'pg';
import { CaseType } from '../enums/case-type';
import { formatSqlString, formatString } from '../helpers/string';

import { getSecretValue } from './../secrets';
import { CovidRDS } from './../secrets/covid-rds';
import { CaseStatistic } from '../models/case-statistic';
import { AgeGenderDistribution } from '../models/age-gender-distribution';
import { Case } from '../models/case';

async function connectionFactory() {
    const { connectionString } = await getSecretValue<CovidRDS>(process.env.COVIDTRACKER_DB_CONNECTION_SECRET_ID!);
    var connection = connectionString.split(";").map(val => val.split('=')).reduce((obj: {[key: string]: string}, val) => {
        obj[val[0]] = val[1];
        return obj;
    }, {})
    return new Client({
        user: connection['User Id'],
        password: connection['Password'],
        host: connection['Server'],
        database: connection['Database'],
        port: parseInt(connection['Port'])
    })
}


async function slonikConnectionFactory() {

}


export async function getAccumulationAsync(type: CaseType) {
    let query = `
    with data as (
        select
            date_trunc('day', {0}) as date,
            count(*)
        from 
            covidtracker.cases
        where
            {1}
        group by 1
        order by 1 asc nulls last
    )
    select 
        date as accumulator,
        sum(count) over (
            order by 
                date asc 
            rows between unbounded 
                preceding and 
                current row
        ) as value
    from data
    order by date desc
    `;

    let datefield = ``;
    let where = ``;

    switch (type) {
        case CaseType.RECOVERED:
            datefield = `dateremoved`;
            where = `removaltype = 'Recovered'`
            break;
        case CaseType.DIED:
            datefield = `dateremoved`;
            where = `removaltype = 'Died'`
            break;
        case CaseType.ADMITTED:
            datefield = `dateconfirmed`;
            where = `admitted and dateremoved is null`
            break;
        default:
        case CaseType.TOTAL:
            datefield = `dateconfirmed`;
            where = `true`
            break;
    }
    query = formatString(query, datefield, where);
    let client = await connectionFactory();
    client.connect();
    return await client.query<CaseStatistic>(query).then(({rows}) => rows).finally(() => { client.end()})
}


export async function getAgeGenderDistributionAsync(type: CaseType) {
    let query = `
        select 
            agegroup as "ageGroup", 
            sex, 
            count(*) as value
        from 
            covidtracker.cases
        where
            {0}
        group by 
            agegroup, sex
        order by 
            sex;
    `;

    let where = ``;

    switch (type) {
        case CaseType.RECOVERED:
            where = `removaltype = 'Recovered'`
            break;
        case CaseType.DIED:
            where = `removaltype = 'Died'`
            break;
        case CaseType.ADMITTED:
            where = `admitted and dateremoved is null`
            break;
        default:
        case CaseType.TOTAL:
            where = `true`
            break;
    }
    query = formatString(query, where);
    let client = await connectionFactory();
    client.connect();
    return client.query<AgeGenderDistribution>(query).then(({rows}) => rows).finally(() => { client.end()})
}

export async function getAllAsync() {
    let query = `
        select
            caseid as "caseId",
            caseno as "caseNo",
            age as age,
            agegroup as "ageGroup",
            sex,
            dateconfirmed as "dateConfirmed",
            daterecovered as "dateRecovered",
            datedied as "dateDied",
            removaltype as "removalType",
            dateremoved as "dateRemoved",
            admitted,
            region,
            province,
            city,
            healthstatus as "healthStatus",
            insertedat as "insertedAt",
            updatedat as "updatedAt"
        from
            covidtracker.cases
    `;
    let client = await connectionFactory();
    client.connect();
    console.log('FETCHING')
    return client.query<Case>(query).then(({rows}) => rows).finally(() => {     console.log('DONE FETCHING');client.end()})
}

export async function getByCaseNoAsync(caseNo: string) {
    let query = `
        select
            caseid as "caseId",
            caseno as "caseNo",
            age as age,
            agegroup as "ageGroup",
            sex,
            dateconfirmed as "dateConfirmed",
            daterecovered as "dateRecovered",
            datedied as "dateDied",
            removaltype as "removalType",
            dateremoved as "dateRemoved",
            admitted,
            region,
            province,
            city,
            healthstatus as "healthStatus",
            insertedat as "insertedAt",
            updatedat as "updatedAt"
        from
            covidtracker.cases
        where
            caseNo = {0}
    `;
    query = formatSqlString(query, caseNo);
    let client = await connectionFactory();
    client.connect();
    return client.query<Case>(query).then(({rows}) => rows[0] || null).finally(() => { client.end()})
}

export async function getStatisticsAsync() {
    let query = `
        with cases as (
            select 
                (removaltype = 'Recovered' or daterecovered is not null) as isrecovered,
                (removaltype = 'Died' or datedied is not null) as isdead,
                (dateremoved is not null) as isremoved,
                admitted,
                dateconfirmed
            from 
                covidtracker.cases
        ),
        caseadmit as (
            select 
                isrecovered,
                isdead,
                (admitted and isremoved = false) as isadmitted
            from 
                cases
        ),
        total as (
            select 
                count(*) 
            from 
                cases
        ),
        total_new as (
            select 
                dateconfirmed,
                count(*) 
            from 
                cases
            group by
                dateconfirmed
            order by
                dateconfirmed desc nulls last
            limit 1
        ),
        recovered as (
            select 
                count(*) 
            from 
                cases 
            where 
                isrecovered
        ),
        dead as (
            select 
                count(*) 
            from 
                cases 
            where 
                isdead
        ),
        admitted as (
            select 
                count(*) 
            from 
                caseadmit 
            where 
                isadmitted
        )
        select 
            (select count from total) as total,
            (select count from total_new) as new,
            (select count from recovered) as recovered,
            (select count from dead) as dead,
            (select count from admitted) as admitted
    `
    let client = await connectionFactory();
    client.connect();
    return await client.query<CaseStatistic>(query).then(({rows}) => rows[0]).finally(() => { client.end()})
}
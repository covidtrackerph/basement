import { Client } from 'pg';
import { CaseType } from '../enums/case-type';
import { formatSqlString, formatString } from '../helpers/string';

import { getSecretValue } from './../secrets';
import { CovidRDS } from './../secrets/covid-rds';
import { CaseStatistic } from '../models/case-statistic';
import { AgeGenderDistribution } from '../models/age-gender-distribution';
import { Case } from '../models/case';
import { SelectionItem } from '../models/residence';
import { DailyStatistic } from '../models/statistic';

async function connectionFactory() {
    const { connectionString } = await getSecretValue<CovidRDS>(process.env.COVIDTRACKER_DB_CONNECTION_SECRET_ID!);
    var connection = connectionString.split(";").map(val => val.split('=')).reduce((obj: { [key: string]: string }, val) => {
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

export async function getDailyStatisticAsync(type: CaseType) {
    let query = `
    select
        date_trunc('day', {0}) as date,
        count(*) as value
    from 
        covidtracker.cases
    where
        {1}
    group by 1
    order by 1 asc nulls last
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
    return await client.query<DailyStatistic>(query).then(({ rows }) => rows).finally(() => { client.end() })
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
    return await client.query<CaseStatistic>(query).then(({ rows }) => rows).finally(() => { client.end() })
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
    return client.query<AgeGenderDistribution>(query).then(({ rows }) => rows).finally(() => { client.end() })
}

export async function getAllAsync(
    region: string = '',
    province: string = '',
    city: string = '',
    offset: number = 0,
    limit: number = 10
) {
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
            case
            when
                length({0}) = 0
            then
                true
            else
                region = {0}
            end
        and
            case
            when
                length({1}) = 0
            then
                true
            else
                province = {1}
            end
        and
            case
            when
                length({2}) = 0
            then
                true
            else
                city = {2}
            end
            order by
            dateconfirmed desc
        offset 
            {3}
        limit 
            {4}
    `;
    let client = await connectionFactory();
    client.connect();
    query = formatSqlString(query, region, province, city, offset, limit);
    return client.query<Case>(query).then(({ rows }) => rows).finally(() => { console.log('DONE FETCHING'); client.end() })
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
    return client.query<Case>(query).then(({ rows }) => rows[0] || null).finally(() => { client.end() })
}

export async function getStatisticsAsync(region: string = '', province: string = '', city: string = '') {
    let query = `
	with cases as (
	    select 
	        (removaltype = 'Recovered' or daterecovered is not null) as isrecovered,
	        (removaltype = 'Died' or datedied is not null) as isdead,
	        (dateremoved is not null) as isremoved,
	        admitted,
	        dateconfirmed,
	        dateremoved,
	        removaltype
	    from 
	        covidtracker.cases
	    where
	        case
	        when
	            length({0}) = 0
	        then
	            true
	        else
	            region = {0}
	        end
	    and
		 	case
	        when
	            length({1}) = 0
	        then
	            true
	        else
	            province = {1}
	        end
		and
		 	case
	        when
	            length({2}) = 0
	        then
	            true
	        else
	            city = {2}
	        end
	),
	caseadmit as (
	    select
	        isrecovered,
	        isdead,
	        (admitted and isremoved = false) as isadmitted,
	        dateconfirmed
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
	recovered_new as (
	    select
	        dateremoved,
	        count(*)
	    from
	        cases
	    where
	        removaltype = 'Recovered'
	    group by
	        dateremoved
	    order by
	        dateremoved desc nulls last
	    limit 1
	),
	dead as (
	    select 
	        count(*) 
	    from 
	        cases 
	    where 
	        isdead
	),
	dead_new as (
	    select 
	        dateremoved,
	        count(*) 
	    from 
	        cases
	    where
	        removaltype = 'Died'
	    group by
	        dateremoved
	    order by
	        dateremoved desc nulls last
	    limit 1
	),
	admitted as (
	    select 
	        count(*) 
	    from 
	        caseadmit 
	    where 
	        isadmitted
	),
	admitted_new as (
	    select 
	        dateconfirmed,
	        count(*) 
	    from 
	        caseadmit
	    group by
	        dateconfirmed
	    order by
	        dateconfirmed desc nulls last
	    limit 1
	)
	select 
	    (select count from total) as total,
	    (select count from total_new) as new,
	    (select count from recovered) as recovered,
	    (select count from recovered_new) as recoveredNew,
	    (select count from dead) as dead,
	    (select count from dead_new) as deadNew,
	    (select count from admitted) as admitted,
	    (select count from admitted_new) as admittedNew   
    `
    query = formatSqlString(query, region, province, city);
    let client = await connectionFactory();
    client.connect();
    return await client.query<CaseStatistic>(query).then(({ rows }) => rows[0]).finally(() => { client.end() })
}


export async function searchRegionsAsync(query: string) {
    let sql = `
    with regions as (
        select 
        (
            case
            when 
                length(region) > 4 
            then
                region
            when
                length(region) = 0
            then
                'For Validation'
            else
                concat('Region ', region)
            end
        ) as display,
        region as value
        from
            covidtracker.cases
        group by 
            region
        order by 
        case
            when
                region = ''
            then 
                1
            end,
            region asc
    )
    select * from regions
    where value ~ {0}
    `
    sql = formatSqlString(sql, query)
    let client = await connectionFactory();
    client.connect();
    return await client.query<SelectionItem>(sql).then(({ rows }) => rows).finally(() => { client.end() })
}


export async function searchProvincesAsync(query: string, region: string = '') {
    if (typeof region === 'string') {
        region = region.trim()
    }

    let sql = `
    with provinces as (
        select 
        (
            case
            when
                length(province) = 0
            then
                'For Validation'
        else
            province
        end
    ) as display,
    province as value
    from
        covidtracker.cases
    where
        case
        when
            length({0}) = 0
        then
            true
        else
            region = {0}
        end
    group by 
        province
    order by 
    case
        when
            province = ''
        then 
            1
        end,
        province asc
    )
    select * from provinces
    where value ~ {1}
    `
    sql = formatSqlString(sql, region, query)
    let client = await connectionFactory();
    client.connect();
    return await client.query<SelectionItem>(sql).then(({ rows }) => rows).finally(() => { client.end() })
}

export async function searchCitiesAsync(query: string, province: string = '', region: string = '') {
    if (typeof region === 'string') {
        region = region.trim()
    }

    if (typeof province === 'string') {
        province = province.trim()
    }

    let sql = `
    with cities as (
        select 
        (
            case
            when
                length(city) = 0
            then
                    'For Validation'
            else
                city
            end
        ) as display,
        city as value
        from
            covidtracker.cases
        where
            case
            when
                length({2}) = 0
            then
                true
            else
                region = {2}
            end
        and
             case
            when
                length({1}) = 0
            then
                true
            else
                province = {1}
            end
        group by 
            city
        order by 
        case
            when
                city = ''
            then 
                1
            end,
            city asc
    )
    select * from cities
    where value ~ {0}
    `
    sql = formatSqlString(sql, query, province, region)
    let client = await connectionFactory();
    client.connect();
    return await client.query<SelectionItem>(sql).then(({ rows }) => rows).finally(() => { client.end() })
}
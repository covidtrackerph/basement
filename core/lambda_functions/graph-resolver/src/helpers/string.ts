import { escape } from 'sqlstring';

export function formatSqlString(template: string, ...params: any[]) {
    return template.replace(/{(\d+)}/g, function (match, number) {
        return typeof params[number] != 'undefined'
            ? escape(params[number])
            : escape(match)
            ;
    });
}

export function formatString(template: string, ...params: any[]) {
    return template.replace(/{(\d+)}/g, function (match, number) {
        return typeof params[number] != 'undefined'
            ? (params[number])
            : (match)
            ;
    });
}
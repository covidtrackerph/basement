
import * as db from './database';
import { CaseType } from './enums/case-type';
export const resolver = {
    cases: () => {
        return db.getAllAsync()
    },
    case: ({ caseNo }: { caseNo: string }) => {
        return db.getByCaseNoAsync(caseNo)
    },
    ageGenderDistribution: ({ type }: { type: CaseType }) => {
        return db.getAgeGenderDistributionAsync(type)
    },
    accumulation: ({ type }: { type: CaseType }) => {
        return db.getAccumulationAsync(type)
    },
    statistics: () => {
        return db.getStatisticsAsync()
    }
}

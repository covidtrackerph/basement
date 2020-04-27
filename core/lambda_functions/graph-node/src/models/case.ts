
export class Case {
    caseNo?: string
    age?: number
    ageGroup?: string
    dateConfirmed?: Date
    dateRecovered?: Date
    dateDied?: Date
    removalType?: string
    dateRemoved?: Date
    admitted?: boolean
    healthStatus?: string
    region?: string
    province?: string
    city?: string
    insertedAt!: Date
    updatedAt!: Date
}
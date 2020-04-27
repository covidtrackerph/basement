using Graph.Models;
using GraphQL.Types;
namespace Graph
{
    public class CaseType : ObjectGraphType<Case>
    {
        public CaseType()
        {
            Field(q => q.CaseNo).Description("Case number assigned by DOH");
            Field(q => q.Age, nullable: true).Description("Age of the person");
            Field(q => q.AgeGroup).Description("Age group of the person");
            Field(q => q.Sex).Description("Sex of the person");
            Field(q => q.DateConfirmed, nullable: true).Description("Date of COVID19 confirmation");
            Field(q => q.DateRecovered, nullable: true).Description("Date of recovery");
            Field(q => q.DateDied, nullable: true).Description("Date of death");
            Field(q => q.RemovalType).Description("Type of removal. Recovered, Died");
            Field(q => q.DateRemoved, nullable: true).Description("Date of removal from confirmed cases");
            Field(q => q.Admitted, nullable: true).Description("Person was admitted");
            Field(q => q.HealthStatus, nullable: true).Description("Health status of the person");
            Field(q => q.Region).Description("Region of residence");
            Field(q => q.Province).Description("Province of residence");
            Field(q => q.City).Description("City of residence");
            Field(q => q.InsertedAt, nullable: true).Description("Record insert date");
            Field(q => q.UpdatedAt, nullable: true).Description("Record update date");
        }
    }
}
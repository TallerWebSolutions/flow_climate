import { Demand, DemandBlocksList } from "../demand/demand.types"
import { ProjectsList } from "../project/project.types"
import { Team } from "../team/team.types"
import User from "../user/user.types"
import { ChartAxisData, KeyValueData } from "../charts/charts.types"

export type TeamMember = {
  id: string
  name: string
  jiraAccountUserEmail: string
  startDate: string
  endDate: string
  billable: boolean
  teams: Team[]
  deliveredDemands?: Demand[]
  bugs?: Demand[]
  demandShortestLeadTime?: Demand
  demandLargestLeadTime?: Demand
  latestDeliveries?: Demand[]
  demandLeadTimeP80?: number
  projectsList?: ProjectsList
  demandBlocksList?: DemandBlocksList
  leadTimeHistogramChartData?: KeyValueData
  leadTimeControlChartData?: ChartAxisData
  memberEffortData?: ChartAxisData
  memberThroughputData?: number[]
  averagePullIntervalData?: ChartAxisData
  user?: User
  projectHoursData?: {
    xAxis: string[]
    yAxisHours: number[]
    yAxisProjectsNames: string[]
  }
}

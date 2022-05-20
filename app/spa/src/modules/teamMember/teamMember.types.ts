import { Demand, DemandBlocksList } from "../demand/demand.types"
import {
  KeyValueData,
  ProjectsList,
  ChartAxisData,
} from "../project/project.types"
import { Team } from "../team/team.types"

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
  projectHoursData?: {
    xAxis: string[]
    yAxisHours: number[]
    yAxisProjectsNames: string[]
  }
}

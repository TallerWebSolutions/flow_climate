import { Demand, DemandBlocksList } from "../demand/demand.types"
import { ProjectsList } from "../project/project.types"
import { Team } from "../team/team.types"
import User from "../user/user.types"
import { ChartAxisData, KeyValueData } from "../charts/charts.types"
import { DemandEffort } from "../demandEffort/demandEffort.types"

type LeadTimesChartData = {
  xAxis: (string | number)[]
  leadTimes: (string | number)[]
  leadTimeP65?: number
  leadTimeP80?: number
  leadTimeP95?: number
}

export type TeamMember = {
  id: string
  name: string
  jiraAccountUserEmail: string
  startDate?: string
  endDate?: string
  billable: boolean
  teams: Team[]
  deliveredDemands?: Demand[]
  bugs?: Demand[]
  demandShortestLeadTime?: Demand
  demandLargestLeadTime?: Demand
  latestDeliveries?: Demand[]
  latestDemandEfforts?: DemandEffort[]
  demandLeadTimeP80?: number
  projectsList?: ProjectsList
  demandBlocksList?: DemandBlocksList
  leadTimeHistogramChartData?: KeyValueData
  leadTimeControlChartData?: LeadTimesChartData
  memberEffortData?: ChartAxisData
  memberEffortDailyData?: ChartAxisData
  memberThroughputData?: number[]
  averagePullIntervalData?: ChartAxisData
  user?: User
  projectHoursData?: {
    xAxis: string[]
    yAxisHours: number[]
    yAxisProjectsNames: string[]
  }
  demandEfforts?: DemandEffort[]
}

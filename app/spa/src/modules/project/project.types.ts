import { Company } from "../company/company.types"
import { Customer } from "../customer/customer.types"
import { Demand } from "../demand/demand.types"
import { Product } from "../product/product.types"
import { ProjectConsolidation } from "./projectConsolidation.types"
import {
  ChartAxisData,
  DemandsFlowChartData,
  KeyValueData,
  NumberChartData,
  SimpleListChartData,
} from "../charts/charts.types"
import { Team } from "../team/team.types"

export type Project = {
  id: string
  company?: Company
  customers?: Customer[]
  products?: Product[]
  latestDeliveries?: Demand[]
  name?: string
  customersNames?: string
  quality?: number
  team?: Team
  status?: string
  qtyHours?: number
  consumedHours?: number
  percentageHoursDelivered?: number
  remainingWeeks?: number
  remainingBacklog?: number
  backlogCountFor?: number
  flowPressure?: number
  flowPressurePercentage?: number
  pastWeeks?: number
  remainingWork?: number
  leadTimeP65?: number
  leadTimeP80?: number
  leadTimeP95?: number
  qtySelected?: number
  qtyInProgress?: number
  monteCarloP80?: number
  maxWorkInProgress?: number
  lastWeekThroughput?: number
  weeklyThroughputs?: number[]
  modeWeeklyTroughputs?: number
  stdDevWeeklyTroughputs?: number
  currentMonteCarloWeeksMin?: number
  currentMonteCarloWeeksMax?: number
  currentMonteCarloWeeksStdDev?: number
  currentWeeksByLittleLaw?: number
  teamMonteCarloP80?: number
  teamMonteCarloWeeksMin?: number
  teamMonteCarloWeeksMax?: number
  teamMonteCarloWeeksStdDev?: number
  teamBasedOddsToDeadline?: number
  customerHappiness?: number
  startDate?: string
  endDate?: string
  aging?: number
  firstDeadline?: string
  daysDifferenceBetweenFirstAndLastDeadlines?: number
  deadlinesChangeCount?: number
  currentCost?: number
  totalHoursConsumed?: number
  averageSpeed?: number
  averageDemandAging?: number
  numberOfDemands?: number
  numberOfDemandsDelivered?: number
  numberOfRemainingBacklog?: number
  totalThroughput?: number
  failureLoad?: number
  discoveredScope?: number
  scope?: number
  initialScope?: number
  projectConsolidations?: ProjectConsolidation[]
  projectConsolidationsWeekly?: ProjectConsolidation[]
  projectConsolidationsLastMonth?: ProjectConsolidation[]
  lastProjectConsolidationsWeekly?: ProjectConsolidation
  currentRiskToDeadline?: number
  remainingDays?: number
  currentTeamBasedRisk?: number
  running?: boolean
  upstreamDemands?: Demand[]
  discardedDemands?: Demand[]
  unscoredDemands?: Demand[]
  demandBlocks?: Demand[]
  demandsFinishedWithLeadtime?: Demand[]
  numberOfDownstreamDemands?: number
  averageQueueTime?: number
  averageTouchTime?: number
  value?: number

  projectMembers: {
    demandsCount?: number
    memberName?: string
  }[]
  hoursPerStageChartData: ChartAxisData
  leadTimeBreakdown: NumberChartData
  demandsFlowChartData: DemandsFlowChartData
  cumulativeFlowChartData?: {
    xAxis: string[]
    yAxis: SimpleListChartData[]
  }
  leadTimeHistogramData: KeyValueData
  demandsBurnup?: Burnup
  hoursBurnup?: Burnup

  totalActiveContractsHours?: number
  consumedActiveContractsHours?: number
  remainingActiveContractsHours?: number
}

export type Burnup = {
  idealBurn?: number[]
  scope?: number[]
  currentBurn?: number[]
  xAxis: string[]
}

export type ProjectsList = {
  totalCount?: number
  projects: Project[]
}

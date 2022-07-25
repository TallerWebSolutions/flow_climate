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
} from "../charts/charts.types"

export type Project = {
  id: string
  name: string
  quality?: number
  team: {
    id: number
    name: string
  }
  status: string
  qtyHours: number
  consumedHours: number
  remainingWeeks: number
  remainingBacklog: number
  backlogCountFor: number
  flowPressure: number
  flowPressurePercentage: number
  pastWeeks: number
  remainingWork: number
  leadTimeP65: number
  leadTimeP80: number
  leadTimeP95: number
  qtySelected: number
  qtyInProgress: number
  monteCarloP80: number
  workInProgressLimit: number
  lastWeekThroughput: number
  weeklyThroughputs: number[]
  modeWeeklyTroughputs: number
  stdDevWeeklyTroughputs: number
  currentMonteCarloWeeksMin: number
  currentMonteCarloWeeksMax: number
  currentMonteCarloWeeksStdDev: number
  currentWeeksByLittleLaw: number
  teamMonteCarloP80: number
  teamMonteCarloWeeksMin: number
  teamMonteCarloWeeksMax: number
  teamMonteCarloWeeksStdDev: number
  teamBasedOddsToDeadline: number
  customers: Customer[]
  products: Product[]
  customerHappiness: number
  startDate: string
  endDate: string
  aging: number
  company?: Company
  firstDeadline: string
  daysDifferenceBetweenFirstAndLastDeadlines: number
  deadlinesChangeCount: number
  currentCost: number
  totalHoursConsumed: number
  averageSpeed: number
  averageDemandAging: number
  numberOfDemands: number
  numberOfDemandsDelivered: number
  numberOfRemainingBacklog: number
  totalThroughput: number
  failureLoad: number
  discoveredScope: number
  scope: number
  initialScope: number
  projectConsolidations: ProjectConsolidation[]
  projectConsolidationsWeekly: ProjectConsolidation[]
  projectConsolidationsLastMonth: ProjectConsolidation[]
  lastProjectConsolidationsWeekly?: ProjectConsolidation
  currentRiskToDeadline?: number
  remainingDays: number
  currentTeamBasedRisk: number
  running: boolean
  upstreamDemands: Demand[]
  discardedDemands: Demand[]
  unscoredDemands: Demand[]
  demandBlocks: Demand[]
  demandsFinishedWithLeadtime: Demand[]
  numberOfDownstreamDemands: number
  averageQueueTime: number
  averageTouchTime: number
  projectMembers: {
    demandsCount: number
    memberName: string
  }[]
  hoursPerStageChartData: ChartAxisData
  leadTimeBreakdown: NumberChartData
  demandsFlowChartData: DemandsFlowChartData
  cumulativeFlowChartData?: {
    xAxis: string[]
    yAxis: {
      name: string
      data: number[]
    }[]
  }
  leadTimeHistogramData: KeyValueData
  currentWeeklyTasksScopeIdealBurnup: number[]
  tasksBurnup?: Burnup
  demandsBurnup?: Burnup
  hoursBurnup?: Burnup
}

export type Burnup = {
  idealBurn: number[]
  scope: number[]
  currentBurn: number[]
  xAxis: string[]
}

export type ProjectsList = {
  totalCount: number
  projects: Project[]
}

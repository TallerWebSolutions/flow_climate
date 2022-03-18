import { Company } from "../company/company.types"
import { Customer } from "../customer/customer.types"
import { Product } from "../product/product.types"
import { ProjectConsolidation } from "./projectConsolidation.types"

export type Project = {
  id: string
  name: string
  remainingWeeks: number
  remainingBacklog: number
  backlogCountFor: number
  flowPressure: number
  flowPressurePercentage: number
  pastWeeks: number
  remainingWork: number
  leadTimeP80: number
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
  company: Company
  firstDeadline: string
  daysDifferenceBetweenFirstAndLastDeadlines: number
  deadlinesChangeCount: number
  currentCost: number
  totalHoursConsumed: number
  averageSpeed: number
  averageDemandAging: number
  totalThroughput: number
  failureLoad: number
  discoveredScope: number
  scope: number
  projectConsolidations: ProjectConsolidation[]
  currentRiskToDeadline: number
  remainingDays: number
  currentTeamBasedRisk: number
  running: boolean
}

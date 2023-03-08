import {
  DemandsFlowChartData,
  KeyValueData,
  SimpleListChartData,
} from "../charts/charts.types"
import { Company } from "../company/company.types"
import { Demand } from "../demand/demand.types"
import { ProjectConsolidation } from "../project/projectConsolidation.types"
import { ReplenishingConsolidation } from "../replenishing/replenishingConsolidation.types"

export type Team = {
  id: string
  name: string
  company?: Company
  increasedLeadtime80: boolean
  throughputData: number[]
  averageThroughput: number
  increasedAvgThroughtput: boolean
  leadTime: number
  workInProgress: number
  maxWorkInProgress: number
  lastReplenishingConsolidations?: ReplenishingConsolidation[]
  startDate?: string
  endDate?: string
  leadTimeP65?: number
  leadTimeP80?: number
  leadTimeP95?: number
  numberOfDemands?: number
  numberOfDemandsDelivered?: number
  numberOfRemainingBacklog?: number
  cumulativeFlowChartData?: {
    xAxis: string[]
    yAxis: SimpleListChartData[]
  }
  biggestFiveLeadTimes?: Demand[]
  biggestFiveLeadTimesInFourWeeks?: Demand[]
  demandsFlowChartData?: DemandsFlowChartData
  leadTimeHistogramData?: KeyValueData
  teamConsolidationsWeekly?: ProjectConsolidation[]
  teamMonthlyInvestment?: {
    xAxis: string[]
    yAxis: number[]
  }
}

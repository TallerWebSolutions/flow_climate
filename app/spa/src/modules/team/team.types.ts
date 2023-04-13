import {
  DemandsFlowChartData,
  KeyValueData,
  NumberChartData,
  SimpleListChartData,
} from "../charts/charts.types"
import { Company } from "../company/company.types"
import { Demand } from "../demand/demand.types"
import { ProjectConsolidation } from "../project/projectConsolidation.types"
import { ReplenishingConsolidation } from "../replenishing/replenishingConsolidation.types"

export type Team = {
  id?: string
  name?: string
  company?: Company
  increasedLeadtime80?: boolean
  throughputData?: number[]
  averageThroughput?: number
  increasedAvgThroughtput?: boolean
  leadTime?: number
  workInProgress?: number
  maxWorkInProgress?: number
  availableHoursInMonthFor?: number
  lastReplenishingConsolidations?: ReplenishingConsolidation[]
  startDate?: string
  endDate?: string
  leadTimeP65?: number
  leadTimeP80?: number
  leadTimeP95?: number
  numberOfDemands?: number
  numberOfDemandsDelivered?: number
  numberOfRemainingBacklog?: number
  activeBillableCount?: number
  cumulativeFlowChartData?: {
    xAxis: string[]
    yAxis: SimpleListChartData[]
  }
  biggestFiveLeadTimes?: Demand[]
  biggestFiveLeadTimesInFourWeeks?: Demand[]
  demandsFlowChartData?: DemandsFlowChartData
  leadTimeHistogramData?: KeyValueData
  teamConsolidationsWeekly?: ProjectConsolidation[]
  teamMonthlyInvestment?: NumberChartData
  teamMemberEfficiency?: MembershipEfficiencyList
  memberships?: Membership[]
}

export type MembershipEfficiencyList = {
  membersEfficiency?: MembershipEfficiencyData[]
  avgHoursPerMember?: number
  avgMoneyPerMember?: number
  totalHoursProduced?: number
  totalMoneyProduced?: number
}

export type MembershipEfficiencyData = {
  membership?: Membership
  effortInMonth?: number
  memberCapacityValue?: number
  realizedMoneyInMonth?: number
  avgHoursPerDemand?: number
  cardsCount?: number
}

export type Membership = {
  id: string
  team: Team
  teamMemberName?: string
  hoursPerMonth?: number
  startDate?: string
  endDate?: string
  memberRole?: number
  memberRoleDescription?: string
}

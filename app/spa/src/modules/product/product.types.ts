import { Company } from "../company/company.types"
import { Demand } from "../demand/demand.types"
import { LeadtimeEvolutionChart } from "../charts/charts.types"
import { PortfolioUnit } from "./portfolioUnit.types"

export type RiskReview = {
  id: string
  leadTimeOutlierLimit?: number
  meetingDate?: string
  monthlyAvgBlockedTime?: number[]
  weeklyAvgBlockedTime?: number[]
  createdAt?: string
}

export type ServiceDeliveryReview = {
  id: string
  delayedExpediteBottomThreshold: number
  delayedExpediteTopThreshold: number
  expediteMaxPullTimeSla: number
  leadTimeBottomThreshold: number
  leadTimeTopThreshold: number
  meetingDate: string
  qualityBottomThreshold: number
  qualityTopThreshold: number
}

export type Product = {
  id: string
  name: string
  slug: string
  company?: Company
  latestDeliveries?: Demand[]
  riskReviews?: RiskReview[]
  portfolioUnits?: PortfolioUnit[]
  remainingBacklogCount: number
  createdDemandsCount: number
  deliveredDemandsCount: number
  upstreamDemandsCount: number
  downstreamDemandsCount: number
  discardedDemandsCount: number
  unscoredDemandsCount: number
  demandsBlocksCount: number
  portfolioUnitsCount: number
  averageSpeed?: number
  averageQueueTime: number
  averageTouchTime: number
  leadtimeP95: number
  leadtimeP80: number
  leadtimeP65: number
  leadtimeEvolutionData?: LeadtimeEvolutionChart
}

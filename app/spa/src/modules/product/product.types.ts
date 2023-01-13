import { Company } from "../company/company.types"
import { Demand } from "../demand/demand.types"
import { LeadtimeEvolutionChart } from "../charts/charts.types"

export type Product = {
  company: Company
  id: string
  name: string
  slug: string
  latestDeliveries: Demand[]
  remainingBacklogCount: number
  createdDemandsCount: number
  deliveredDemandsCount: number
  upstreamDemandsCount: number
  downstreamDemandsCount: number
  discardedDemandsCount: number
  unscoredDemandsCount: number
  demandsBlocksCount: number
  portfolioUnitsCount: number
  averageSpeed: number
  averageQueueTime: number
  averageTouchTime: number
  leadtimeP95: number
  leadtimeP80: number
  leadtimeP65: number

  leadtimeEvolutionData: LeadtimeEvolutionChart
}

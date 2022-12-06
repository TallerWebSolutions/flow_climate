import { Company } from "../company/company.types"
import { Demand } from "../demand/demand.types"

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
  averageSpeed: number
  averageQueueTime: number
  averageTouchTime: number
  leadTimeP95: number
  leadTimeP80: number
  leadTimeP65: number
}

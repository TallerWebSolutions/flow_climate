import { Company } from "../company/company.types"
import { Project } from "../project/project.types"

export type Demand = {
  id: string
  demandTitle?: string
  endDate?: string
  createdDate: string
  product: {
    id: string
    name: string
  }
  customer?: {
    id: string
    name: string
  }
  externalId: string
  leadtime: number
  numberOfBlocks: number
  project?: Project
  company?: Company
}

export type DemandsList = {
  demands: Demand[]
  lastPage: boolean
  totalCount: number
  totalPages: number
}

export type DemandBlock = {
  id: string
  demand: Demand
  blockTime: string
  unblockTime: string
}

export type DemandBlocksList = {
  demandBlocks: DemandBlock[]
}

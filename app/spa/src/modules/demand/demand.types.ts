import { Project } from "../project/project.types"

export type Demand = {
  id: string
  demandTitle?: string
  endDate: string
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
}

export type DemandBlock = {
  id: string
  demand: Demand
  blockTime: string
  unblockTime: string
}

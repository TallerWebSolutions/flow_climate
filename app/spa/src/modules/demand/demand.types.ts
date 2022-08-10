import { Company } from "../company/company.types"
import { Project } from "../project/project.types"
import ControlChart from "../charts/controlChart.types"
import { TeamMember } from "../teamMember/teamMember.types"
import { DemandsFlowChartData, NumberChartData } from "../charts/charts.types"

export type Demand = {
  id: string
  demandTitle?: string
  demandType: string
  endDate?: string
  commitmentDate?: string
  createdDate: string
  product: {
    id: string
    name: string
  }
  customer?: {
    id: string
    name: string
  }
  responsibles?: TeamMember[]
  externalId: string
  leadtime: number
  numberOfBlocks: number
  project?: Project
  company?: Company
  costToProject?: number
  effortUpstream?: number
  effortDownstream?: number
  portfolioUnit?: PortfolioUnit
}

type PortfolioUnit = {
  id: string
  name: string
}

export type DemandsList = {
  demands: Demand[]
  lastPage: boolean
  totalCount: number
  totalPages: number
  controlChart: ControlChart
  leadTimeBreakdown: NumberChartData
  flowData: DemandsFlowChartData
  flowEfficiency: NumberChartData
  leadTimeEvolutionP80: NumberChartData
}

export type DemandBlock = {
  id: string
  demand?: Demand
  blockTime?: string
  unblockTime?: string
}

export type DemandBlocksList = {
  demandBlocks: DemandBlock[]
}

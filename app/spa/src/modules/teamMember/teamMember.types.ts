import { Demand } from "../demand/demand.types"
import { Project } from "../project/project.types"
import { Team } from "../team/team.types"

export type TeamMember = {
  id: string
  name: string
  jiraAccountUserEmail: string
  startDate: string
  endDate: string
  billable: boolean
  teams: Team[]
  deliveredDemands?: Demand[]
  bugs?: Demand[]
  demandShortestLeadTime?: Demand
  demandLargestLeadTime?: Demand
  demandLeadTimeP80?: number
  projects: Project[]
}

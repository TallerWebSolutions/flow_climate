import { Initiative } from "../initiative/initiative.types"
import { Project } from "../project/project.types"
import { Team } from "../team/team.types"

type Demand = {
  demandTitle: string
}

export type Task = {
  id: number
  externalId: number
  title: string
  createdDate: string | Date
  endDate: string | Date
  delivered: boolean
  secondsToComplete: number
  partialCompletionTime: number
  team: Team
  project: Project
  initiative: Initiative | null
  demand: Demand
}

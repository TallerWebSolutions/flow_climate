import { Initiative } from "../initiative/initiative.types"
import { Project } from "../project/project.types"
import { Team } from "../team/team.types"

type Demand = {
  demandTitle: string
}

export type Task = {
  id: number
  title: string
  createdDate: string
  endDate: string
  secondsToComplete: number
  partialCompletionTime: number
  team: Team
  project: Project
  initiative: Initiative
  demand: Demand
}

import { Initiative } from "../initiative/initiative.types"
import { Project } from "../project/project.types"
import { Team } from "../team/team.types"

type WorkItemType = {
  id: string
  name: string
}

export type Company = {
  id: string
  name: string
  slug: string
  initiatives?: Initiative[]
  projects?: Project[]
  teams?: Team[]
  workItemTypes?: WorkItemType[]
}

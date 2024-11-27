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
  projects?: Project[]
  teams?: Team[]
  workItemTypes?: WorkItemType[]
}

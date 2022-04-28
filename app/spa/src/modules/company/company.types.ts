import { Initiative } from "../initiative/initiative.types"
import { Project } from "../project/project.types"
import { Team } from "../team/team.types"

export type Company = {
  id: string
  name: string
  slug: string
  initiatives?: Initiative[]
  projects?: Project[]
  teams?: Team[]
}

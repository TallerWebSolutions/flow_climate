import { Project } from "../project/project.types"
import { Team } from "../team/team.types"
import { Product } from "../product/product.types"

export type WorkItemType = {
  id: string
  name: string
}

export type Company = {
  id: string
  name?: string
  slug?: string
  projects?: Project[]
  products?: Product[]
  teams?: Team[]
  workItemTypes?: WorkItemType[]
}

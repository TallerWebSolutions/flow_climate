import { Project } from "../project/project.types"

export type ReplenishingConsolidation = {
  id: string
  consolidationDate: string
  createdAt: string
  project: Project
  customerHappiness: number
}

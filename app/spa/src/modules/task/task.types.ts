import { Initiative } from "../initiative/initiative.types"
import { Project } from "../project/project.types"
import { Team } from "../team/team.types"
import { KeyValueData } from "../charts/charts.types"
import { Demand } from "../demand/demand.types"

export type Task = {
  id: number
  externalId: number
  title: string
  taskType: string
  createdDate: string
  endDate?: string
  delivered: boolean
  secondsToComplete: number
  partialCompletionTime: number
  team: Team
  project: Project
  initiative: Initiative | null
  demand: Demand
}

export type TasksList = {
  totalCount: number
  tasks: Task[]
  tasksCharts: {
    xAxis: string[]
    creation: number[]
    throughput: number[]
    completionPercentilesOnTimeArray: number[]
    accumulatedCompletionPercentilesOnTimeArray: number[]
  }
  deliveredLeadTimeP65: number
  deliveredLeadTimeP80: number
  deliveredLeadTimeP95: number
  inProgressLeadTimeP65: number
  inProgressLeadTimeP80: number
  inProgressLeadTimeP95: number
  completiontimeHistogramChartData: KeyValueData
}

type Demand = {
  id: number
  demandTitle: string
}

export type Task = {
  id: number
  demand: Demand
  createdDate: string
  endDate: string
  secondsToComplete: number
  partialCompletionTime: number
}

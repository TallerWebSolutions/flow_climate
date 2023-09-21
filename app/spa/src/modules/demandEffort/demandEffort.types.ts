export type DemandEffort = {
  id: string
  effortValue?: number
  effortMoney?: number
  startTimeToComputation?: string
  finishTimeToComputation?: string
  stagePercentage?: number
  pairingPercentage?: number
  managementPercentage?: number
  totalBlocked?: number
  mainEffortInTransition?: number
  stage?: string
  who?: string
  memberRole?: string
  automaticUpdate?: boolean
  membershipEffortPercentage?: number
}

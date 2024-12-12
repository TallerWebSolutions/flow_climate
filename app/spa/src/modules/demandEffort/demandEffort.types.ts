import { Membership, Team } from "../team/team.types"

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
  updatedAt?: string
  createdAt?: string
  automaticUpdate?: boolean
  membershipEffortPercentage?: number
  team?: Team
  demandId?: number
  demandExternalId?: string
  itemAssignment?: ItemAssignment
}

type ItemAssignment = {
  id: number
  membership?: Membership
}

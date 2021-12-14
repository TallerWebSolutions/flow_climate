import { Fragment } from "react"
import { Container } from "@mui/material"
import { gql, useQuery } from "@apollo/client"

import ReplenishmentTeamInfo from "../components/ReplenishmentTeamInfo"
import ReplenishingProjectsInfo, {
  Project,
} from "../components/ReplenishmentProjectsInfo"

const QUERY = gql`
  query Replenishment {
    team(id: 1) {
      id
      name
      throughputData
      averageThroughput
      increasedAvgThroughtput
      leadTime
      increasedLeadtime80
      workInProgress
      lastReplenishingConsolidations(orderBy: "consolidation_date", direction: "asc", limit: 1) {
        id
        project {
          id
          name
          remainingWeeks
          remainingBacklog
          flowPressure
          flowPressurePercentage
          leadTimeP80
          qtySelected
          qtyInProgress
          monteCarloP80
        }
      }
    }
  }
`

export const normalizeTeamInfo = (data: any) => (
    {
      throughputData: data.team.throughputData,
      averageThroughput: {
        value: data.team.averageThroughput,
        increased: data.team.increasedAvgThroughtput
      },
      leadTime: {
        value: data.team.leadTime,
        increased: data.team.increasedLeadtime80
      },
      workInProgress: data.team.workInProgress
    }
)

const Replenishment = () => {
  const { data, loading, error } = useQuery(QUERY)

  if (error) {
    console.error(error)
  }

  if (loading) return <Container>"carregando..."</Container>

  const projects: Project[] = []

  return (
      <Container>
        {data?.team && (
            <Fragment>
              <ReplenishmentTeamInfo team={normalizeTeamInfo(data)} />
              <ReplenishingProjectsInfo projects={projects} />
            </Fragment>
        )}
      </Container>
  )
}

export default Replenishment

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
      teamThroughputData
      averageTeamThroughput
      teamLeadTime
      teamWip
    }
    project {
      id
      name
    }
  }
`

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
          <ReplenishmentTeamInfo team={data.team} />
          <ReplenishingProjectsInfo projects={projects} />
        </Fragment>
      )}
    </Container>
  )
}

export default Replenishment

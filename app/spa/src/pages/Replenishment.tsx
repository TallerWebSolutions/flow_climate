import { Fragment } from "react"
import { Container } from "@mui/material"
import { gql, useQuery } from "@apollo/client"

import ReplenishmentTeamInfo from "../components/ReplenishmentTeamInfo"

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
  }
`

const Replenishment = () => {
  const { data, loading, error } = useQuery(QUERY)

  if (error) {
    console.error(error)
  }

  if (loading) return <Container>"carregando..."</Container>

  return (
    <Container>
      {!data?.teams && (
        <Fragment>
          <ReplenishmentTeamInfo teamProps={ data }  />
        </Fragment>
      )}
    </Container>
  )
}

export default Replenishment

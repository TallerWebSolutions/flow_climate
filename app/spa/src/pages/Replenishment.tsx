import { Container } from "@mui/material"
import { gql, useQuery } from "@apollo/client"

import ReplenishmentTeamInfo from "../components/ReplenishmentTeamInfo"
import { Fragment } from "react"

const QUERY = gql`
  query Replenishment {
    team(id: 1) {
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

  console.log({ data })

  return (
    <Container>
      {!data?.teams && (
        <Fragment>
          <ReplenishmentTeamInfo />
        </Fragment>
      )}
    </Container>
  )
}

export default Replenishment

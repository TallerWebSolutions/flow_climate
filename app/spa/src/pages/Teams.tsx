import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress } from "@mui/material"
import BasicPage from "../components/BasicPage"
import { Team } from "./Replenishing"

export const TEAMS_QUERY = gql`
  query Teams($id: Int!) {
    project(id: $id) {
      id
      company {
        id
        name
        slug
      }
    }

    teams {
      id
      name
    }
  }
`

export type TeamsDTO = Team[] | undefined

const Teams = () => {
  const { data, loading } = useQuery<TeamsDTO>(TEAMS_QUERY)

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const company = data?.team.company
  const companyName = company?.name
  const companyUrl = `/companies/${company?.slug}`

  const breadcrumbsLinks = [
    { name: companyName, url: companyUrl },
    {
      name: "Lista dos Times",
    },
  ]

  return (
    <BasicPage title={"Teams"} breadcrumbsLinks={[]}>
      <p>Teams</p>
    </BasicPage>
  )
}

export default Teams

import { gql, useQuery } from "@apollo/client"
import {
  Backdrop,
  CircularProgress,
  Table,
  TableCell,
  TableHead,
  TableRow,
  Typography,
} from "@mui/material"
import BasicPage from "../components/BasicPage"
import { Team } from "./Replenishing"
import { Company } from "../modules/company/company.types"
import { ReactElement } from "react"
import { capitalizeFirstLetter } from "../lib/func"

export const TEAMS_QUERY = gql`
  query Teams {
    teams {
      id
      name
    }

    me {
      currentCompany {
        name
        slug
      }
    }
  }
`

type LoggedUser = {
  currentCompany: Company
}

export type TeamsDTO = {
  teams: Team[]
  me: LoggedUser
}

type TableItemProps = {
  children: ReactElement | ReactElement[]
}

const TableItem = ({ children }: TableItemProps) => {
  return (
    <TableRow>
      <TableCell>{children}</TableCell>
    </TableRow>
  )
}

const Teams = () => {
  const { data, loading } = useQuery<TeamsDTO>(TEAMS_QUERY)

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const company = data?.me.currentCompany
  const companyName = company?.slug
  const companyUrl = `/companies/${company?.slug}`

  const breadcrumbsLinks = [
    { name: capitalizeFirstLetter(companyName!), url: companyUrl! },
    {
      name: "Lista dos Times",
    },
  ]

  return (
    <BasicPage title={"Teams"} breadcrumbsLinks={breadcrumbsLinks}>
      <Table>
        <TableHead>
          <TableCell>
            <Typography>Times</Typography>
          </TableCell>
        </TableHead>

        <TableRow>
          <TableCell>Text</TableCell>
        </TableRow>

        <TableRow>
          <TableCell>Text</TableCell>
        </TableRow>
      </Table>
    </BasicPage>
  )
}

export default Teams

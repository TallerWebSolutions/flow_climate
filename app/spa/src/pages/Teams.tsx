import { gql, useQuery } from "@apollo/client"
import {
  Backdrop,
  Box,
  Button,
  CircularProgress,
  Link,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography,
} from "@mui/material"
import EditOutlinedIcon from "@mui/icons-material/EditOutlined"
import DeleteOutlineOutlinedIcon from "@mui/icons-material/DeleteOutlineOutlined"
import BasicPage from "../components/BasicPage"
import { Team } from "./Replenishing"
import { Company } from "../modules/company/company.types"
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
  const teams = data?.teams

  const breadcrumbsLinks = [
    { name: capitalizeFirstLetter(companyName!), url: companyUrl! },
    {
      name: "Lista dos Times",
    },
  ]

  return (
    <BasicPage
      title={"Teams"}
      company={company}
      breadcrumbsLinks={breadcrumbsLinks}
    >
      <Box sx={{ display: "flex", justifyContent: "center", mt: 3 }}>
        <Table sx={{ flex: "0 0 50%" }}>
          <TableHead>
            <TableRow>
              <TableCell>
                <Typography color="text.primary" sx={{ fontSize: "1.25rem" }}>
                  Times
                </Typography>
              </TableCell>
            </TableRow>
          </TableHead>

          <TableBody>
            {teams?.map(({ name, id }, index) => {
              const teamLinkBase = `/companies/taller/teams/${id}`

              return (
                <TableRow
                  key={`${name}-${index}`}
                  sx={{ display: "flex", justifyContent: "space-between" }}
                >
                  <TableCell>
                    <Link
                      href={teamLinkBase}
                      sx={{ textDecorationColor: "info.dark" }}
                    >
                      <Typography color="info.dark">{name}</Typography>
                    </Link>
                  </TableCell>
                  <TableCell
                    size={"small"}
                    sx={{ display: "inline-flex", whiteSpace: "nowrap" }}
                  >
                    <Box mr={1}>
                      <Link href={`${teamLinkBase}/edit`}>
                        <EditOutlinedIcon color={"primary"} />
                      </Link>
                    </Box>

                    <Link href={`${teamLinkBase}/delete`}>
                      <DeleteOutlineOutlinedIcon color={"primary"} />
                    </Link>
                  </TableCell>
                </TableRow>
              )
            })}
          </TableBody>
        </Table>

        <Button
          href="/companies/taller/teams/new"
          variant="contained"
          sx={{ height: "35", textTransform: "uppercase", color: "primary" }}
        >
          Criar Time
        </Button>
      </Box>
    </BasicPage>
  )
}

export default Teams

import { gql, useMutation, useQuery } from "@apollo/client"
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
import BasicPage, { MessagesContext } from "../components/BasicPage"
import { Team } from "./Replenishing"
import { Company } from "../modules/company/company.types"
import { capitalizeFirstLetter } from "../lib/func"
import { useConfirm } from "material-ui-confirm"
import { useContext } from "react"

const TEAMS_QUERY = gql`
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

const DELETE_TEAM_MUTATION = gql`
  mutation DeleteTeam($teamId: String!) {
    deleteTeam(teamId: $teamId) {
      statusMessage
    }
  }
`

type DeleteTeamDTO = {
  deleteTeam: {
    statusMessage: string
  }
}

type LoggedUser = {
  currentCompany: Company
}

export type TeamsDTO = {
  teams: Team[]
  me: LoggedUser
}

const Teams = () => {
  const { data, loading } = useQuery<TeamsDTO>(TEAMS_QUERY)
  const [deleteTeam] = useMutation<DeleteTeamDTO>(DELETE_TEAM_MUTATION, {
    update: (_, { data }) => {
      console.log({ data })
    },
    refetchQueries: [{ query: TEAMS_QUERY }],
  })

  const { pushMessage } = useContext(MessagesContext)
  const deleteTeamModal = useConfirm()

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

  const handleOnDeleteTeam = (id: string) => {
    pushMessage({
      text: "Sua solicitação foi colocada na fila. Em poucos minutos estará pronta.",
      severity: "info",
    })
    // deleteTeamModal({
    //   title: "Tem certeza?",
    //   description: "Essa ação é permanente!",
    // }).then(() => {
    //   deleteTeam({
    //     variables: { teamId: id },
    //   })

    //   pushMessage({
    //     text: "Time deletado",
    //     severity: "info",
    //   })
    // })
  }

  return (
    <>
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

                      <Button onClick={() => handleOnDeleteTeam(id)}>
                        <DeleteOutlineOutlinedIcon color={"primary"} />
                      </Button>
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
    </>
  )
}

export default Teams

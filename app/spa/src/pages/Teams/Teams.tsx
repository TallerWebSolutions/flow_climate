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
import BasicPage from "../../components/BasicPage"
import { capitalizeFirstLetter } from "../../lib/func"
import { useConfirm } from "material-ui-confirm"
import { useContext, useEffect } from "react"
import { MessagesContext } from "../../contexts/MessageContext"
import { useTranslation } from "react-i18next"
import User from "../../modules/user/user.types"
import { Team } from "../../modules/team/team.types"

export const TEAMS_QUERY = gql`
  query Teams {
    teams {
      id
      name
    }

    me {
      language
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

export type TeamsDTO = {
  teams: Team[]
  me: User
}

const Teams = () => {
  const { t, i18n } = useTranslation(["teams"])
  const { pushMessage } = useContext(MessagesContext)
  const { data, loading } = useQuery<TeamsDTO>(TEAMS_QUERY)
  const [deleteTeam] = useMutation<DeleteTeamDTO>(DELETE_TEAM_MUTATION, {
    update: (_, { data }) => {
      const mutationResult = data?.deleteTeam.statusMessage === "SUCCESS"

      pushMessage({
        text: mutationResult
          ? t("deleted_team_message_success")
          : t("deleted_team_message_fail"),
        severity: mutationResult ? "success" : "error",
      })
    },
    refetchQueries: [{ query: TEAMS_QUERY }],
  })
  const deleteTeamModal = useConfirm()

  useEffect(() => {
    if (!loading) i18n.changeLanguage(data?.me.language)
  }, [loading, data, i18n])

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
      name: t("teams_list"),
    },
  ]

  const handleOnDeleteTeam = (id: string) => {
    deleteTeamModal({
      title: t("delete_team_modal_title"),
      description: t("delete_team_modal_body"),
    }).then(() => {
      deleteTeam({
        variables: { teamId: id },
      })
    })
  }

  return (
    <>
      <BasicPage
        title={t("teams")}
        company={company}
        breadcrumbsLinks={breadcrumbsLinks}
      >
        <Box sx={{ display: "flex", justifyContent: "center", mt: 3 }}>
          <Table sx={{ flex: "0 0 50%" }}>
            <TableHead>
              <TableRow>
                <TableCell>
                  <Typography color="text.primary" sx={{ fontSize: "1.25rem" }}>
                    {t("teams")}
                  </Typography>
                </TableCell>
              </TableRow>
            </TableHead>

            <TableBody data-testid="teams-list">
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
            {t("create_team_button")}
          </Button>
        </Box>
      </BasicPage>
    </>
  )
}

export default Teams
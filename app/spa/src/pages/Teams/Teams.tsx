import { gql, useMutation, useQuery } from "@apollo/client"
import DeleteOutlineOutlinedIcon from "@mui/icons-material/DeleteOutlineOutlined"
import EditOutlinedIcon from "@mui/icons-material/EditOutlined"
import { Link as RouterLink } from "react-router-dom"
import {
  Box,
  Button,
  Link,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography,
} from "@mui/material"
import { useConfirm } from "material-ui-confirm"
import { useContext, useEffect } from "react"
import { useTranslation } from "react-i18next"
import BasicPage from "../../components/BasicPage"
import { MessagesContext } from "../../contexts/MessageContext"
import { MeContext } from "../../contexts/MeContext"
import { Team } from "../../modules/team/team.types"
import User from "../../modules/user/user.types"
import * as amplitude from "../../amplitude/amplitudeEvents"
import { trackPageView } from "../../amplitude/amplitudeEvents"

export const TEAMS_QUERY = gql`
  query Teams {
    teams {
      id
      name
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
  const { t } = useTranslation(["teams"])
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
  const { me } = useContext(MeContext)

  const company = me?.currentCompany
  const companySlug = company?.slug
  const teams = data?.teams
  const companyUrl = `/companies/${companySlug}`
  const companyName = company?.name || t("company")

  const breadcrumbsLinks = [
    { name: companyName || "", url: companyUrl },
    {
      name: t("teams_list"),
    },
  ]

  const handleOnDeleteTeam = (id: string) => {
    amplitude.logEvent("Excluir Time", {
      teamId: id,
      device_id: "abcdefg",
    })

    deleteTeamModal({
      title: t("delete_team_modal_title"),
      description: t("delete_team_modal_body"),
    }).then(() => {
      deleteTeam({
        variables: { teamId: id },
      })
    })
  }

  const amplitudeUser = {
    id: me?.id,
    fullName: me?.fullName,
    companySlug: me?.currentCompany?.slug,
  }

  useEffect(() => {
    if (amplitudeUser?.id)
      return trackPageView("Teams", amplitudeUser?.id, { user: amplitudeUser })
  })

  return (
    <BasicPage
      title={t("teams")}
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
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
              const teamLinkBase = `/companies/${companySlug}/teams/${id}`

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

                    {id && (
                      <Button onClick={() => handleOnDeleteTeam(id)}>
                        <DeleteOutlineOutlinedIcon color={"primary"} />
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              )
            })}
          </TableBody>
        </Table>

        <Button
          component={RouterLink}
          to={`/companies/${companySlug}/teams/new`}
          variant="contained"
        >
          {t("create_team_button")}
        </Button>
      </Box>
    </BasicPage>
  )
}

export default Teams

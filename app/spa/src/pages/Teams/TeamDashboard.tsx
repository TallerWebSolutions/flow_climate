import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress, Grid } from "@mui/material"
import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"

import DateLocale from "../../components/ui/DateLocale"
import Table from "../../components/ui/Table"
import { MeContext } from "../../contexts/MeContext"
import { secondsToDays } from "../../lib/date"
import TeamBasicPage from "../../modules/team/components/TeamBasicPage"
import { Team } from "../../modules/team/team.types"

const TEAM_DASHBOARD_QUERY = gql`
  query TeamDashboard($teamId: Int!) {
    team(id: $teamId) {
      id
      name
      startDate
      endDate
      leadTimeP65
      leadTimeP80
      leadTimeP95
      numberOfDemandsDelivered
      cumulativeFlowChartData {
        xAxis
        yAxis {
          name
          data
        }
      }
    }
  }
`

type TeamDashboardDTO = {
  team: Team
}

const TeamDashboard = () => {
  const { t } = useTranslation("teams")
  const { teamId, companySlug } = useParams()
  const { me } = useContext(MeContext)
  const { data, loading } = useQuery<TeamDashboardDTO>(TEAM_DASHBOARD_QUERY, {
    variables: { teamId: Number(teamId) },
  })

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const company = me?.currentCompany
  const companyName = company?.name
  const companyUrl = `/companies/${companySlug}`
  const team = data?.team
  const breadcrumbsLinks = [
    { name: companyName || "", url: companyUrl },
    { name: team?.name || "" },
  ]

  const teamInfoRows = team
    ? [
        [t("dashboard.name"), team.name],
        [
          t("dashboard.startDate"),
          team.startDate ? <DateLocale date={team.startDate} /> : "",
        ],
        [
          t("dashboard.endDate"),
          team.endDate ? <DateLocale date={team.endDate} /> : "",
        ],
        [t("dashboard.delivered"), team.numberOfDemandsDelivered || 0],
        [
          t("dashboard.leadTimeP65"),
          `${secondsToDays(team.leadTimeP65 || 0)} ${t("dashboard.days")}`,
        ],
        [
          t("dashboard.leadTimeP80"),
          `${secondsToDays(team.leadTimeP80 || 0)} ${t("dashboard.days")}`,
        ],
        [
          t("dashboard.leadTimeP95"),
          `${secondsToDays(team.leadTimeP95 || 0)} ${t("dashboard.days")}`,
        ],
      ]
    : []

  return (
    <TeamBasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
      title={team?.name}
    >
      <Grid container columnSpacing={4}>
        <Grid item xs={4} sx={{ padding: 2 }}>
          <Table title={t("dashboard.infoTable")} rows={teamInfoRows} />
        </Grid>
      </Grid>
    </TeamBasicPage>
  )
}

export default TeamDashboard

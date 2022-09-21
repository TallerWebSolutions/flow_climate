import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress, Grid } from "@mui/material"
import { SliceTooltipProps } from "@nivo/line"
import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { ChartGridItem } from "../../components/charts/ChartGridItem"
import { LineChart, normalizeCfdData } from "../../components/charts/LineChart"
import LineChartTooltip from "../../components/charts/tooltips/LineChartTooltip"

import DateLocale from "../../components/ui/DateLocale"
import Table from "../../components/ui/Table"
import { MeContext } from "../../contexts/MeContext"
import { cfdChartData } from "../../lib/charts"
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

  const cumulativeFlowChartData = team?.cumulativeFlowChartData
  const cfdXaxis = cumulativeFlowChartData?.xAxis || []
  const cfdYaxis = cumulativeFlowChartData?.yAxis.reverse() || []
  const teamStages = cfdYaxis.map((item) => item.name)
  const teamCumulativeFlowChartData = cfdChartData(
    teamStages,
    cfdXaxis,
    cfdYaxis
  )

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
        {teamCumulativeFlowChartData && (
          <ChartGridItem
            title={t("charts.cumulativeFlowChart", {
              teamName: team?.name,
            })}
            columns={8}
          >
            <LineChart
              data={normalizeCfdData(teamCumulativeFlowChartData)}
              axisLeftLegend={t("charts.cumulativeFlowYLabel")}
              props={{
                yScale: {
                  type: "linear",
                  stacked: true,
                },
                areaOpacity: 1,
                enableArea: true,
                enableSlices: "x",
                sliceTooltip: ({ slice }: SliceTooltipProps) => (
                  <LineChartTooltip slice={slice} />
                ),
                margin: { left: 80, right: 20, top: 25, bottom: 65 },
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legendPosition: "middle",
                  legendOffset: 60,
                  tickRotation: -40,
                },
              }}
            />
          </ChartGridItem>
        )}
      </Grid>
    </TeamBasicPage>
  )
}

export default TeamDashboard

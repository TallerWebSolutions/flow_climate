import { Grid, Typography } from "@mui/material"
import { useTranslation } from "react-i18next"
import { secondsToDays } from "../lib/date"

import { TeamMember } from "../modules/teamMember/teamMember.types"
import { BarChart } from "./charts/BarChart"
import { ScatterChart } from "./charts/ScatterChart"

type TeamMemberDashboardChartsProps = {
  teamMember: TeamMember
}

const TeamMemberDashboardCharts = ({
  teamMember,
}: TeamMemberDashboardChartsProps) => {
  const { t } = useTranslation(["teamMembers"])
  const leadTimeHistogramChartData = {
    ...teamMember.leadTimeHistogramChartData,
    values: teamMember.leadTimeHistogramChartData?.values || [],
    keys: teamMember.leadTimeHistogramChartData?.keys.map(secondsToDays) || [],
  }
  const leadTimeControlChartData = {
    ...teamMember.leadTimeControlChartData,
    xAxis: teamMember.leadTimeControlChartData?.xAxis || [],
    yAxis: teamMember.leadTimeControlChartData?.yAxis.map(secondsToDays) || [],
  }
  const leadTimeControlChartMarkers = [
    {
      value: secondsToDays(leadTimeControlChartData?.leadTimeP65 || 0),
      legend: t("charts.ltP65"),
    },
    {
      value: secondsToDays(leadTimeControlChartData?.leadTimeP80 || 0),
      legend: t("charts.ltP80"),
    },
    {
      value: secondsToDays(leadTimeControlChartData?.leadTimeP95 || 0),
      legend: t("charts.ltP95"),
    },
  ]

  return (
    <Grid container spacing={2}>
      {leadTimeHistogramChartData && (
        <Grid item xs={6}>
          <Typography component="h3">
            {t("charts.leadTimeHistogram")}
          </Typography>
          <BarChart
            indexBy="key"
            data={leadTimeHistogramChartData}
            keys={["value"]}
            padding={0}
          />
        </Grid>
      )}
      {leadTimeControlChartData && (
        <Grid item xs={6}>
          <Typography component="h3">{t("charts.leadTimeControl")}</Typography>
          <ScatterChart
            data={leadTimeControlChartData}
            markers={leadTimeControlChartMarkers}
          />
        </Grid>
      )}
    </Grid>
  )
}

export default TeamMemberDashboardCharts

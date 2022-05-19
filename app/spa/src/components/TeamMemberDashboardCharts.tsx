import { Grid, Typography } from "@mui/material"
import { useTranslation } from "react-i18next"

import { secondsToDays } from "../lib/date"
import { axisDataToKeyValue } from "../lib/charts"
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
  const memberEffortData = {
    ...teamMember.memberEffortData,
    xAxis: teamMember.memberEffortData?.xAxis || [],
    yAxis: teamMember.memberEffortData?.yAxis.map(secondsToDays) || [],
  }

  const memberThroughputData = teamMember.memberThroughputData?.map(
    (th, index) => ({
      key: th,
      value: index,
    })
  )

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
      {memberEffortData && (
        <Grid item xs={6}>
          <Typography component="h3">{t("charts.memberEffort")}</Typography>
          <BarChart
            data={axisDataToKeyValue(memberEffortData)}
            keys={["value"]}
            indexBy="key"
          />
        </Grid>
      )}
      {memberThroughputData && (
        <Grid item xs={6}>
          <Typography component="h3">{t("charts.throughput")}</Typography>
          <BarChart
            data={memberThroughputData}
            keys={["value"]}
            indexBy="key"
          />
        </Grid>
      )}
    </Grid>
  )
}

export default TeamMemberDashboardCharts

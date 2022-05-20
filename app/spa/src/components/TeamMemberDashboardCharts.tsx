import { Grid, Typography } from "@mui/material"
import { useTranslation } from "react-i18next"

import { secondsToDays } from "../lib/date"
import { axisDataToKeyValue } from "../lib/charts"
import { TeamMember } from "../modules/teamMember/teamMember.types"
import { BarChart } from "./charts/BarChart"
import { ScatterChart } from "./charts/ScatterChart"
import { BarDatum } from "@nivo/bar"

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
  const leadTimeP65 = secondsToDays(leadTimeControlChartData?.leadTimeP65 || 0)
  const leadTimeP80 = secondsToDays(leadTimeControlChartData?.leadTimeP80 || 0)
  const leadTimeP95 = secondsToDays(leadTimeControlChartData?.leadTimeP95 || 0)
  const leadTimeControlChartMarkers = [
    {
      value: leadTimeP65,
      legend: t("charts.ltP65", { leadtime: leadTimeP65 }),
    },
    {
      value: secondsToDays(leadTimeControlChartData?.leadTimeP80 || 0),
      legend: t("charts.ltP80", { leadtime: leadTimeP80 }),
    },
    {
      value: secondsToDays(leadTimeControlChartData?.leadTimeP95 || 0),
      legend: t("charts.ltP95", { leadtime: leadTimeP95 }),
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
  const averagePullIntervalData = teamMember.averagePullIntervalData
  const projectHoursData = teamMember.projectHoursData
  const projectHoursKeys = projectHoursData?.xAxis || []
  const projectHoursNames = projectHoursData?.yAxisProjectsNames || []
  const projectHoursGroups: BarDatum[] =
    projectHoursKeys?.map((key, indexKeys, { length: lengthKeys }) => {
      const group: BarDatum = { key }
      projectHoursNames.forEach((name, indexNames) => {
        group[name] =
          projectHoursData?.yAxisHours[indexKeys * lengthKeys + indexNames] ||
          ""
      })
      return group
    }) || []

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
      {averagePullIntervalData && (
        <Grid item xs={6}>
          <Typography component="h3">
            {t("charts.averagePullInterval")}
          </Typography>
          <BarChart
            data={axisDataToKeyValue(averagePullIntervalData)}
            keys={["value"]}
            indexBy="key"
          />
        </Grid>
      )}
      {projectHoursData && (
        <Grid item xs={12}>
          <Typography component="h3">{t("charts.hoursPerProject")}</Typography>
          <BarChart
            data={projectHoursGroups}
            keys={projectHoursNames}
            indexBy="key"
            groupMode="grouped"
          />
        </Grid>
      )}
    </Grid>
  )
}

export default TeamMemberDashboardCharts

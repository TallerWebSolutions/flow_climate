import { Grid } from "@mui/material"
import { useTranslation } from "react-i18next"
import { BarDatum } from "@nivo/bar"

import { secondsToDays } from "../lib/date"
import { axisDataToKeyValue } from "../lib/charts"
import { TeamMember } from "../modules/teamMember/teamMember.types"
import { BarChart } from "./charts/BarChart"
import { ScatterChart } from "./charts/ScatterChart"
import { ChartGridItem } from "./charts/ChartGridItem"
import TeamMemberEffortDailyData from "../modules/teamMember/components/TeamMemberEffortDailyData"

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
    yAxis:
      teamMember.leadTimeControlChartData?.leadTimes.map(secondsToDays) || [],
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
    yAxis: teamMember.memberEffortData?.yAxis || [],
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
  const projectHoursGroups: BarDatum[] = projectHoursKeys.map(
    (key, indexKeys, { length: lengthKeys }) => {
      const group: BarDatum = { key }
      projectHoursNames.forEach((name, indexNames) => {
        group[name] =
          projectHoursData?.yAxisHours[indexKeys * lengthKeys + indexNames] ||
          ""
      })
      return group
    }
  )

  return (
    <Grid container spacing={2}>
      {leadTimeHistogramChartData && (
        <ChartGridItem title={t("charts.leadTimeHistogram")}>
          <BarChart
            indexBy="key"
            data={leadTimeHistogramChartData}
            keys={["value"]}
            padding={0}
          />
        </ChartGridItem>
      )}
      {leadTimeControlChartData && (
        <ChartGridItem title={t("charts.leadTimeControl")}>
          <ScatterChart
            data={leadTimeControlChartData}
            markers={leadTimeControlChartMarkers}
          />
        </ChartGridItem>
      )}
      <TeamMemberEffortDailyData teamMember={teamMember} />
      {memberEffortData && (
        <ChartGridItem title={t("charts.memberEffort")}>
          <BarChart
            data={axisDataToKeyValue(memberEffortData)}
            legendLabel={t("charts.memberEffort_legend_label")}
            axisBottomLegend={t("charts.memberEffort_x_label")}
            axisLeftLegend={t("charts.memberEffort_y_label")}
            keys={["value"]}
            indexBy="key"
          />
        </ChartGridItem>
      )}
      {memberThroughputData && (
        <ChartGridItem title={t("charts.throughput")}>
          <BarChart
            data={memberThroughputData}
            keys={["value"]}
            indexBy="key"
          />
        </ChartGridItem>
      )}
      {averagePullIntervalData && (
        <ChartGridItem title={t("charts.averagePullInterval")}>
          <BarChart
            data={axisDataToKeyValue(averagePullIntervalData)}
            keys={["value"]}
            indexBy="key"
          />
        </ChartGridItem>
      )}
      {projectHoursData && (
        <ChartGridItem title={t("charts.hoursPerProject")}>
          <BarChart
            data={projectHoursGroups}
            keys={projectHoursNames}
            indexBy="key"
            groupMode="grouped"
          />
        </ChartGridItem>
      )}
    </Grid>
  )
}

export default TeamMemberDashboardCharts

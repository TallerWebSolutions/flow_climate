import { Grid } from "@mui/material"
import { useTranslation } from "react-i18next"
import { BarDatum } from "@nivo/bar"

import { formatDate, secondsToDays } from "../lib/date"
import { axisDataToKeyValue } from "../lib/charts"
import { TeamMember } from "../modules/teamMember/teamMember.types"
import { BarChart } from "./charts/BarChart"
import { ScatterChart } from "./charts/ScatterChart"
import { ChartGridItem } from "./charts/ChartGridItem"
import TeamMemberEffortDailyData from "../modules/teamMember/components/TeamMemberEffortDailyData"
import { LineChart } from "./charts/LineChart"
import { SliceTooltipProps } from "@nivo/line"
import LineChartTooltip from "./charts/tooltips/LineChartTooltip"
import { formatCurrency } from "../lib/currency"

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
  const leadTimeP65 = secondsToDays(leadTimeControlChartData?.leadTimeP65)
  const leadTimeP80 = secondsToDays(leadTimeControlChartData?.leadTimeP80)
  const leadTimeP95 = secondsToDays(leadTimeControlChartData?.leadTimeP95)
  const leadTimeControlChartMarkers = [
    {
      value: leadTimeP65,
      legend: t("charts.ltP65", { leadtime: leadTimeP65 }),
    },
    {
      value: secondsToDays(leadTimeControlChartData?.leadTimeP80),
      legend: t("charts.ltP80", { leadtime: leadTimeP80 }),
    },
    {
      value: secondsToDays(leadTimeControlChartData?.leadTimeP95),
      legend: t("charts.ltP95", { leadtime: leadTimeP95 }),
    },
  ]
  const memberEffortData = {
    ...teamMember.memberEffortData,
    xAxis:
      teamMember.memberEffortData?.xAxis.map((dateStr) =>
        formatDate({
          date: dateStr as string,
          format: t("charts.memberEffort_x_date_format"),
        })
      ) || [],
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

  const lineChartTeamMemberHourValueData =
    teamMember?.teamMemberHourValueChartList?.map((teamMemberHourValueList) => {
      return {
        id: teamMemberHourValueList.team?.name ?? "",
        data:
          teamMemberHourValueList.memberHourValueChartData?.map(
            (memberHourValueChartData) => {
              return {
                x: String(memberHourValueChartData.date || ""),
                y: String(
                  memberHourValueChartData.hourValueRealized?.toFixed(2) || 0
                ),
              }
            }
          ) ?? [],
      }
    }) ?? []

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
      {lineChartTeamMemberHourValueData && (
        <ChartGridItem title={t("charts.valuePerHour")}>
          <LineChart
            data={lineChartTeamMemberHourValueData}
            axisLeftLegend={t("charts.valuePerHour")}
            axisBottomLegend={t("charts.memberEffort_x_label")}
            props={{
              enableSlices: "x",
              sliceTooltip: ({ slice }: SliceTooltipProps) => (
                <LineChartTooltip slice={slice} />
              ),
            }}
          />
        </ChartGridItem>
      )}
    </Grid>
  )
}

export default TeamMemberDashboardCharts

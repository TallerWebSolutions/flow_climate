import { ChartGridItem } from "../../../components/charts/ChartGridItem"
import { LineChart } from "../../../components/charts/LineChart"
import { Project } from "../../../modules/project/project.types"
import { useTranslation } from "react-i18next"
import { SliceTooltipProps } from "@nivo/line"
import LineChartTooltip from "../../../components/charts/tooltips/LineChartTooltip"

const ProjectFlowEfficiency = ({ project }: ProjectFlowEfficiencyProps) => {
  const { t } = useTranslation(["projectChart"])

  const projectConsolidationsWeekly = project.projectConsolidationsWeekly
  const flowEfficiencyChartData = [
    {
      id: project.name || "",
      data:
        projectConsolidationsWeekly?.map(
          ({ consolidationDate, flowEfficiency }) => {
            return {
              x: consolidationDate,
              y: flowEfficiency,
            }
          }
        ) || [],
    },
  ]

  return (
    <ChartGridItem title={t("chartsTab.projectCharts.flow_efficiency_chart")}>
      <LineChart
        data={flowEfficiencyChartData}
        axisLeftLegend={"%"}
        props={{
          margin: { left: 80, right: 20, top: 25, bottom: 65 },
          axisBottom: {
            tickSize: 5,
            tickPadding: 5,
            legendPosition: "middle",
            legendOffset: 60,
            tickRotation: -40,
            legend: t("chartsTab.projectCharts.hours_consumed_x_label"),
          },
          yFormat: (value: number) => `${value}%`,
          enableSlices: "x",
          sliceTooltip: ({ slice }: SliceTooltipProps) => (
            <LineChartTooltip
              slice={slice}
              xLabel={t(
                "chartsTab.projectCharts.flow_efficiency_tooltip_label"
              )}
            />
          ),
        }}
      />
    </ChartGridItem>
  )
}

type ProjectFlowEfficiencyProps = {
  project: Project
}

export default ProjectFlowEfficiency

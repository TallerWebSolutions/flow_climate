import {
  LineChart,
  normalizeCfdData,
} from "../../../components/charts/LineChart"
import { SliceTooltipProps } from "@nivo/line"
import LineChartTooltip from "../../../components/charts/tooltips/LineChartTooltip"
import { ChartGridItem } from "../../../components/charts/ChartGridItem"
import { Project } from "../../../modules/project/project.types"
import { useTranslation } from "react-i18next"
import { cfdChartData } from "../../../lib/charts"

const ProjectCumulativeFlowData = ({
  project,
}: ProjectCumulativeFlowDataProps) => {
  const { t } = useTranslation(["projectChart"])

  const cumulativeFlowChartData = project.cumulativeFlowChartData
  const cfdXaxis = cumulativeFlowChartData?.xAxis || []
  const cfdYaxis = [...(cumulativeFlowChartData?.yAxis || [])].reverse()
  const projectStages = cfdYaxis.map((item) => item.name)
  const projectCumulativeFlowChartData = cfdChartData(
    projectStages,
    cfdXaxis,
    cfdYaxis
  )

  return (
    <ChartGridItem
      title={t("chartsTab.projectCharts.cumulative_flow_chart", {
        projectName: project.name,
      })}
    >
      <LineChart
        data={normalizeCfdData(projectCumulativeFlowChartData)}
        axisLeftLegend={t("chartsTab.projectCharts.cumulative_flow_y_label")}
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
            legend: t("chartsTab.projectCharts.cumulative_flow_x_label"),
          },
        }}
      />
    </ChartGridItem>
  )
}

type ProjectCumulativeFlowDataProps = {
  project: Project
}

export default ProjectCumulativeFlowData

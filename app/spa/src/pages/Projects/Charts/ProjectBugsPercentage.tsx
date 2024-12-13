import { LineChart } from "../../../components/charts/LineChart"
import { SliceTooltipProps } from "@nivo/line"
import LineChartTooltip from "../../../components/charts/tooltips/LineChartTooltip"
import { ChartGridItem } from "../../../components/charts/ChartGridItem"
import { Project } from "../../../modules/project/project.types"
import { useTranslation } from "react-i18next"

const ProjectBugsPercentage = ({ project }: ProjectBugsPercentageProps) => {
  const { t } = useTranslation(["projectChart"])

  const projectConsolidationsWeekly = project.projectConsolidationsWeekly
  const projectQualityChartData = [
    {
      id: project.name || "",
      data:
        projectConsolidationsWeekly?.map(
          ({ consolidationDate, projectQuality }) => ({
            x: consolidationDate,
            y: (1 - (projectQuality || 0)) * 100,
          })
        ) || [],
    },
  ]

  return (
    <ChartGridItem title={t("chartsTab.projectCharts.quality_bugs_chart")}>
      <LineChart
        data={projectQualityChartData}
        axisLeftLegend="%"
        props={{
          margin: { left: 80, right: 20, top: 25, bottom: 65 },
          axisBottom: {
            tickSize: 5,
            tickPadding: 5,
            legendPosition: "middle",
            legendOffset: 60,
            tickRotation: -40,
            legend: t("chartsTab.projectCharts.quality_bugs_x_label"),
          },
          yFormat: (value: number) => `${value.toFixed(2)}%`,
          enableSlices: "x",
          sliceTooltip: ({ slice }: SliceTooltipProps) => (
            <LineChartTooltip
              slice={slice}
              xLabel={t("chartsTab.projectCharts.quality_bugs_tooltip_label")}
            />
          ),
        }}
      />
    </ChartGridItem>
  )
}

type ProjectBugsPercentageProps = {
  project: Project
}

export default ProjectBugsPercentage

import { LineChart } from "../../../components/charts/LineChart"
import { SliceTooltipProps } from "@nivo/line"
import LineChartTooltip from "../../../components/charts/tooltips/LineChartTooltip"
import { ChartGridItem } from "../../../components/charts/ChartGridItem"
import { Project } from "../../../modules/project/project.types"
import { useTranslation } from "react-i18next"

const ProjectOperationalRiskEvolution = ({
  project,
}: ProjectOperationalRiskEvolutionProps) => {
  const { t } = useTranslation(["projectChart"])

  const projectConsolidationsWeekly = project.projectConsolidationsWeekly
  const operationalRiskChartData = [
    {
      id: t("chartsTab.projectCharts.operational_math_risk_evolution_chart"),
      data:
        projectConsolidationsWeekly?.map(
          ({ consolidationDate, operationalRisk }) => {
            return {
              x: consolidationDate || "",
              y: (operationalRisk || 0) * 100,
            }
          }
        ) || [],
    },
  ]

  return (
    <ChartGridItem
      title={t("chartsTab.projectCharts.operational_math_risk_evolution_chart")}
    >
      <LineChart
        data={operationalRiskChartData}
        axisLeftLegend={`${t(
          "chartsTab.projectCharts.operational_math_risk_evolution_y_label"
        )} (%)`}
        props={{
          margin: { left: 80, right: 20, top: 25, bottom: 65 },
          axisBottom: {
            tickSize: 5,
            tickPadding: 5,
            legendPosition: "middle",
            legendOffset: 60,
            tickRotation: -40,
          },
          enableSlices: "x",
          yFormat: (value: number) => `${value.toFixed(2)}%`,
          sliceTooltip: ({ slice }: SliceTooltipProps) => (
            <LineChartTooltip
              slice={slice}
              xLabel={t(
                "chartsTab.projectCharts.operational_math_risk_evolution_tooltip_label"
              )}
            />
          ),
        }}
      />
    </ChartGridItem>
  )
}

type ProjectOperationalRiskEvolutionProps = {
  project: Project
}

export default ProjectOperationalRiskEvolution

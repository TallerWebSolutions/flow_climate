import { LineChart } from "../../../components/charts/LineChart"
import { SliceTooltipProps } from "@nivo/line"
import LineChartTooltip from "../../../components/charts/tooltips/LineChartTooltip"
import { ChartGridItem } from "../../../components/charts/ChartGridItem"
import { useTranslation } from "react-i18next"
import { Project } from "../../../modules/project/project.types"
import { buildBurnupData } from "../../../utils/charts"

type ProjectBurnupProps = {
  project: Project
}
const ProjectBurnup = ({ project }: ProjectBurnupProps) => {
  const { t } = useTranslation(["projectChart"])

  const projectDemandsBurnupChartData = buildBurnupData(
    t("chartsTab.projectCharts.demands_burn_up_label_scope"),
    t("chartsTab.projectCharts.demands_burn_up_label_ideal"),
    t("chartsTab.projectCharts.demands_burn_up_label_delivered"),
    project.demandsBurnup
  )

  return (
    <ChartGridItem
      title={t("chartsTab.projectCharts.demandsBurnupChart", {
        projectName: project.name,
      })}
    >
      <LineChart
        data={projectDemandsBurnupChartData}
        axisLeftLegend={t("chartsTab.projectCharts.demandsBurnupYLabel")}
        props={{
          enableSlices: "x",
          sliceTooltip: ({ slice }: SliceTooltipProps) => (
            <LineChartTooltip slice={slice} />
          ),
        }}
      />
    </ChartGridItem>
  )
}

export default ProjectBurnup

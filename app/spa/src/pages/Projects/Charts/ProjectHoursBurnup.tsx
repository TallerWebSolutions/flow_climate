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

const ProjectHoursBurnup = ({ project }: ProjectBurnupProps) => {
  const { t } = useTranslation(["projectChart"])

  const projectHoursBurnupChartData = buildBurnupData(
    t("chartsTab.projectCharts.hoursBurnUpLabelScope"),
    t("chartsTab.projectCharts.hoursBurnUpLabelIdeal"),
    t("chartsTab.projectCharts.hoursBurnUpLabelDelivered"),
    project.hoursBurnup
  )

  return (
    <ChartGridItem
      title={t("chartsTab.projectCharts.hoursBurnUpChart", {
        projectName: project.name,
      })}
    >
      <LineChart
        data={projectHoursBurnupChartData}
        axisLeftLegend={t("chartsTab.projectCharts.hoursBurnUpYLabel")}
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

export default ProjectHoursBurnup

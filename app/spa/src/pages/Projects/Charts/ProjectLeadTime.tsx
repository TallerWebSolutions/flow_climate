import { LineChart } from "../../../components/charts/LineChart"
import { SliceTooltipProps } from "@nivo/line"
import LineChartTooltip from "../../../components/charts/tooltips/LineChartTooltip"
import { ChartGridItem } from "../../../components/charts/ChartGridItem"
import { secondsToDays } from "../../../lib/date"
import { Project } from "../../../modules/project/project.types"
import { useTranslation } from "react-i18next"

const ProjectLeadTime = ({ project }: ProjectLeadTimeProps) => {
  const { t } = useTranslation(["projectChart"])

  const projectConsolidationsWeekly = project.projectConsolidationsWeekly
  const leadTimeP80ChartData = [
    {
      id: project.name || "",
      data:
        projectConsolidationsWeekly?.map(
          ({ leadTimeP80, consolidationDate }) => {
            const leadTimeP80InDays = secondsToDays(leadTimeP80)

            return {
              x: consolidationDate,
              y: leadTimeP80InDays,
            }
          }
        ) || [],
    },
  ]

  return (
    <ChartGridItem title={t("chartsTab.projectCharts.lead_time_p80_chart")}>
      <LineChart
        data={leadTimeP80ChartData}
        axisLeftLegend={t("chartsTab.projectCharts.lead_time_p80_y_label")}
        axisBottomLegend={t("chartsTab.projectCharts.lead_time_p80_x_label")}
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

type ProjectLeadTimeProps = {
  project: Project
}

export default ProjectLeadTime

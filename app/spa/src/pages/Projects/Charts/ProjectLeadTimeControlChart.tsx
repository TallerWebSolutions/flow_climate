import { ScatterChart } from "../../../components/charts/ScatterChart"
import { ChartGridItem } from "../../../components/charts/ChartGridItem"
import { secondsToDays } from "../../../lib/date"
import { useTranslation } from "react-i18next"
import { useNavigate } from "react-router-dom"
import { useContext } from "react"
import { MeContext } from "../../../contexts/MeContext"
import { Project } from "../../../modules/project/project.types"

const ProjectLeadTimeControlChart = ({
  project,
}: ProjectLeadTimeControlChartProps) => {
  const { t } = useTranslation(["projectChart"])
  const navigate = useNavigate()
  const { me } = useContext(MeContext)

  const demandsFinishedWithLeadtime = project.demandsFinishedWithLeadtime
  const leadTimeControlChartData = [
    {
      id: t("chartsTab.projectCharts.lead_time_control_label"),
      data:
        demandsFinishedWithLeadtime?.map(({ externalId, leadtime }) => {
          const leadTimeInDays = secondsToDays(leadtime)

          return {
            x: externalId || "",
            y: leadTimeInDays || 0,
          }
        }) || [],
    },
  ]

  const lastProjectConsolidationsWeekly =
    project.lastProjectConsolidationsWeekly
  const leadTimeP65InDays = secondsToDays(
    lastProjectConsolidationsWeekly?.leadTimeP65
  )
  const leadTimeP80InDays = secondsToDays(
    lastProjectConsolidationsWeekly?.leadTimeP80
  )
  const leadTimeP95InDays = secondsToDays(
    lastProjectConsolidationsWeekly?.leadTimeP95
  )

  const leadTimeControlP65Marker = {
    value: leadTimeP65InDays,
    legend: t("chartsTab.projectCharts.lead_time_control_marker_p65", {
      leadTime: leadTimeP65InDays,
    }),
  }

  const leadTimeControlP80Marker = {
    value: leadTimeP80InDays,
    legend: t("chartsTab.projectCharts.lead_time_control_marker_p80", {
      leadTime: leadTimeP80InDays,
    }),
  }

  const leadTimeControlP95Marker = {
    value: leadTimeP95InDays,
    legend: t("chartsTab.projectCharts.lead_time_control_marker_p95", {
      leadTime: leadTimeP95InDays,
    }),
  }

  return (
    <ChartGridItem title={t("chartsTab.projectCharts.lead_time_control_chart")}>
      <ScatterChart
        data={leadTimeControlChartData}
        axisLeftLegend={t("chartsTab.projectCharts.lead_time_control_y_label")}
        axisBottomLegend={t(
          "chartsTab.projectCharts.lead_time_control_x_label"
        )}
        markers={[
          leadTimeControlP65Marker,
          leadTimeControlP80Marker,
          leadTimeControlP95Marker,
        ]}
        onClick={(props) => {
          navigate(
            `/companies/${me?.currentCompany?.slug}/demands/${props.data.x}`
          )
        }}
      />
    </ChartGridItem>
  )
}

type ProjectLeadTimeControlChartProps = {
  project: Project
}

export default ProjectLeadTimeControlChart

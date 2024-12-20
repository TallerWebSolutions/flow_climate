import { ChartGridItem } from "../../../components/charts/ChartGridItem"
import PieChart from "../../../components/charts/PieChart"
import { Project } from "../../../modules/project/project.types"
import { useTranslation } from "react-i18next"

const ProjectDeliveriesByClassOfService = ({
  project,
}: ProjectDeliveriesByClassOfServiceProps) => {
  const { t } = useTranslation(["projectChart"])

  const classesOfService = [
    ...new Set(
      project.demandsFinishedWithLeadtime?.map(
        (demand) => demand.classOfService
      )
    ),
  ]
  const deliveriesByClassOfServiceChartData = classesOfService.map((cos) => ({
    label: cos,
    value: project.demandsFinishedWithLeadtime?.filter(
      (d) => d.classOfService === cos
    ).length,
  }))

  return (
    <ChartGridItem
      title={t("chartsTab.projectCharts.deliveriesByClassOfService")}
    >
      <PieChart data={deliveriesByClassOfServiceChartData} />
    </ChartGridItem>
  )
}

type ProjectDeliveriesByClassOfServiceProps = {
  project: Project
}

export default ProjectDeliveriesByClassOfService

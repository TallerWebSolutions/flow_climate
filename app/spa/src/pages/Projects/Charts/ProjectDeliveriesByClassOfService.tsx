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
  const deliveriesByClassOfServiceChartData = classesOfService.map((cos) => {
    const demandsAmount =
      project.demandsFinishedWithLeadtime?.filter(
        (d) => d.classOfService === cos
      ).length || 0

    return {
      label: `${cos} ${(
        (demandsAmount / (project.demandsFinishedWithLeadtime?.length || 1)) *
        100
      ).toFixed(2)}%`,
      value: demandsAmount,
    }
  })

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

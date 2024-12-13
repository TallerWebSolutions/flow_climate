import { useTranslation } from "react-i18next"
import ProjectChartsTable from "../../components/Projects/ProjectChartsTable"
import { ProjectPage } from "../../components/Projects/ProjectPage"
import DemandsCharts from "./DemandsCharts"

const Project = () => {
  const { t } = useTranslation(["projects"])

  return (
    <ProjectPage pageName={t("charts")}>
      <ProjectChartsTable />
      <DemandsCharts />
    </ProjectPage>
  )
}

export default Project

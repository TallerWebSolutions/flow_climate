import { useContext } from "react"
import { Box } from "@mui/material"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"

import { Tabs } from "../../components/Tabs"
import { MeContext } from "../../contexts/MeContext"
import { ProjectChartsTable } from "../../components/ProjectChartsTable"
import { ProjectPage } from "../../components/ProjectPage"
import DemandsCharts from "./DemandsCharts"

const Project = () => {
  const { t } = useTranslation(["project"])

  return (
    <ProjectPage pageName={t("charts")} dashboard>
      <ProjectChartsTable />
      <DemandsCharts />
    </ProjectPage>
  )
}

export default Project

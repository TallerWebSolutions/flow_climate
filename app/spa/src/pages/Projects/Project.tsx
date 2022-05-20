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
  const { me } = useContext(MeContext)
  const { projectId } = useParams()

  const taskTabs = [
    {
      label: t("tabs.demands"),
      to: `/companies/${me?.currentCompany?.slug}/projects/${projectId}`,
    },
    {
      label: t("tabs.tasks"),
      to: `/companies/${me?.currentCompany?.slug}/projects/${projectId}/tasks`,
    },
  ]

  return (
    <ProjectPage pageName={t("charts")}>
      <ProjectChartsTable />

      <Box
        sx={{
          mt: 2,
          mb: 6,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <Tabs tabs={taskTabs} currentPath="" />
      </Box>
      <DemandsCharts />
    </ProjectPage>
  )
}

export default Project

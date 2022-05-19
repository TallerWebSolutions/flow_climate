import { useState } from "react"
import { Box, Tab, Tabs } from "@mui/material"
import { useTranslation } from "react-i18next"
import { ProjectChartsTable } from "../../components/ProjectChartsTable"
import { ProjectPage } from "../../components/ProjectPage"
import TabPanel from "../../components/TabPanel"
import DemandsCharts from "./DemandsCharts"
import TasksCharts from "./TasksCharts"

type ProjectPageProps = {
  initialTab?: number
}

const a11yProps = (index: number) => {
  return {
    id: `simple-tab-${index}`,
    "aria-controls": `simple-tabpanel-${index}`,
  }
}

const Project = ({ initialTab = 0 }: ProjectPageProps) => {
  const { t } = useTranslation(["project"])
  const [tab, setTab] = useState(initialTab)

  const taskTabs = [
    {
      label: t("tabs.demands"),
    },
    {
      label: t("tabs.tasks"),
    },
  ]

  const handleChangeTab = (tab: number) => {
    setTab(tab)
  }

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
        <Tabs value={tab} onChange={(_, tab) => handleChangeTab(tab)}>
          {taskTabs.map((tab, index) => {
            return (
              <Tab
                key={`${index}--${tab.label}`}
                label={tab.label}
                {...a11yProps(index)}
              />
            )
          })}
        </Tabs>
      </Box>

      <TabPanel value={tab} index={0}>
        <DemandsCharts />
      </TabPanel>

      <TabPanel value={tab} index={1}>
        <TasksCharts />
      </TabPanel>
    </ProjectPage>
  )
}

export default Project

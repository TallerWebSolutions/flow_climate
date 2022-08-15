import { Box } from "@mui/material"
import { useState, useContext } from "react"
import { useTranslation } from "react-i18next"

import TaskList from "./List"
import { MeContext } from "../../contexts/MeContext"
import TasksPage, { TaskFilters } from "../../modules/task/components/TasksPage"

const Tasks = () => {
  const { t } = useTranslation(["tasks"])
  const [taskFilters, setTaskFilters] = useState<TaskFilters>({
    page: 0,
    limit: 10,
    status: "",
  })
  const { me } = useContext(MeContext)

  const company = me?.currentCompany

  const breadcrumbsLinks = [
    { name: String(company?.name) || "", url: String(company?.slug) },
    { name: t("tasks_list") },
  ]

  return (
    <TasksPage
      filters={taskFilters}
      setFilters={setTaskFilters}
      breadcrumbsLinks={breadcrumbsLinks}
    >
      <Box>
        <TaskList filters={taskFilters} setFilters={setTaskFilters} />
      </Box>
    </TasksPage>
  )
}

export default Tasks

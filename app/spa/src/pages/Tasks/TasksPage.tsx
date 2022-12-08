import { Box } from "@mui/material"
import { useState, useContext } from "react"
import { useTranslation } from "react-i18next"

import TasksTable from "../../modules/task/components/TasksTable"
import { MeContext } from "../../contexts/MeContext"
import TasksList, { TaskFilters } from "../../modules/task/components/TasksList"

const TasksPage = () => {
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
    <TasksList
      filters={taskFilters}
      setFilters={setTaskFilters}
      breadcrumbsLinks={breadcrumbsLinks}
    >
      <Box>
        <TasksTable filters={taskFilters} setFilters={setTaskFilters} />
      </Box>
    </TasksList>
  )
}

export default TasksPage

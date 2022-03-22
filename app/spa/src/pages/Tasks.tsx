import { gql, useQuery } from "@apollo/client"
import {
  Backdrop,
  Box,
  CircularProgress,
  Link,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TablePagination,
  TableRow,
  Typography,
} from "@mui/material"
import { ChangeEvent, useState } from "react"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import BasicPage from "../components/BasicPage"
import { secondsToReadbleDate } from "../lib/date"
import { Task } from "../modules/task/task.types"

const TASKS_QUERY = gql`
  query Tasks($page: Int!, $limit: Int) {
    tasks(pageParam: $page, limit: $limit) {
      id
      demand {
        id
        demandTitle
      }
      createdDate
      endDate
      secondsToComplete
      partialCompletionTime
    }
  }
`

type TasksDTO = {
  tasks: Task[]
}

const normalizeTimeToFinish = (
  secondsToComplete: number,
  partialCompletionTime: number
) => {
  if (!secondsToComplete) {
    return secondsToReadbleDate(partialCompletionTime)
  }

  return secondsToReadbleDate(secondsToComplete)
}

const Tasks = () => {
  const { t } = useTranslation(["tasks"])
  const { companyNickName } = useParams()
  const [listPage, setListPage] = useState(1)
  const [rowsPerPage, setRowsPerPage] = useState(10)

  const { data, loading } = useQuery<TasksDTO>(TASKS_QUERY, {
    variables: {
      page: listPage,
      limit: rowsPerPage,
    },
  })

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const tasks = data?.tasks!
  const numberOfTasks = tasks.length
  const taskListHeadCells = [
    "ID",
    t("tasks_table.demand"),
    t("tasks_table.demand_title"),
    t("tasks_table.creation_date"),
    t("tasks_table.delivery_date"),
    t("tasks_table.time_to_finish"),
  ]

  const handleRowsPerPage = (
    event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const quantity: number = Number(event.target.value)
    setRowsPerPage(quantity)
  }

  const handleChangePage = (newPage: number) => {
    setListPage(newPage)
  }

  return (
    <BasicPage title={t("tasks")} breadcrumbsLinks={[]}>
      <Box>
        <TableContainer>
          <Typography color="primary" variant="h6" component="h6">
            {`877 ${t("tasks")} - 405 ${t("finished_tasks")}`}
          </Typography>

          <Table>
            <TableHead
              sx={{
                borderBottom: "1px solid",
                borderBottomColor: "#ccc",
              }}
            >
              <TableRow>
                {taskListHeadCells.map((cellName, index) => (
                  <TableCell key={`${index}--${cellName}`}>
                    {cellName}
                  </TableCell>
                ))}
              </TableRow>
            </TableHead>

            <TableBody>
              {tasks.map((row, index) => (
                <TableRow
                  sx={{
                    borderBottom: "1px solid",
                    borderBottomColor: "#ccc",
                  }}
                  key={`${row.demand}--${index}`}
                >
                  <TableCell padding="checkbox">
                    <Link
                      href={`/companies/${companyNickName}/tasks/${row.id}`}
                    >
                      {row.id}
                    </Link>
                  </TableCell>
                  <TableCell padding="checkbox">{row.demand.id}</TableCell>
                  <TableCell padding="checkbox">
                    {row.demand.demandTitle}
                  </TableCell>
                  <TableCell padding="checkbox">{row.createdDate}</TableCell>
                  <TableCell padding="checkbox">{row.endDate}</TableCell>
                  <TableCell padding="checkbox">
                    {normalizeTimeToFinish(
                      row.secondsToComplete,
                      row.partialCompletionTime
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>

          <TablePagination
            labelRowsPerPage={t("tasks_table.rows_per_page")}
            labelDisplayedRows={({ from, to, count }) => {
              return `${from}-${to} ${t(
                "tasks_table.count_displayed_items_separator"
              )} ${count}`
            }}
            rowsPerPageOptions={[5, 10, 25]}
            component="div"
            count={numberOfTasks}
            rowsPerPage={rowsPerPage}
            page={listPage}
            onPageChange={(_, page) => handleChangePage(page)}
            onRowsPerPageChange={(event) => handleRowsPerPage(event)}
          />
        </TableContainer>
      </Box>
    </BasicPage>
  )
}

export default Tasks

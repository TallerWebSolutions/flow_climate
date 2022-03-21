import {
  Box,
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
import BasicPage from "../components/BasicPage"

const Tasks = () => {
  const { t } = useTranslation(["tasks"])
  const [rowsPerPage, setRowsPerPage] = useState(10)
  const [listPage, setListPage] = useState(1)

  const data = [
    {
      id: 1,
      demand: "2465",
      title: "Title",
      creation_date: "12/02/22",
      deleivery_date: "12/02/22",
      time_to_finish: "21 dias e 11 horas",
    },
    {
      id: 1,
      demand: "2465",
      title: "Title",
      creation_date: "12/02/22",
      deleivery_date: "12/02/22",
      time_to_finish: "21 dias e 11 horas",
    },
  ]
  const numberOfTasks = data.length

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
    <BasicPage title={"Tarefas"} breadcrumbsLinks={[]}>
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
              {data.map((row, index) => (
                <TableRow
                  sx={{
                    borderBottom: "1px solid",
                    borderBottomColor: "#ccc",
                  }}
                  key={`${row.demand}--${index}`}
                >
                  {Object.values(row).map((value) => (
                    <TableCell padding="checkbox">{value}</TableCell>
                  ))}
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

import SearchIcon from "@mui/icons-material/Search"
import {
  Box,
  Button,
  FormGroup,
  Grid,
  Input,
  InputLabel,
  Select,
} from "@mui/material"
import { Dispatch, ReactNode, SetStateAction, useContext } from "react"
import { useTranslation } from "react-i18next"
import { FieldValues, useForm } from "react-hook-form"

import { MeContext } from "../../../contexts/MeContext"
import BasicPage, { BasicPageProps } from "../../../components/BasicPage"
import { Tabs } from "../../../components/Tabs"
import { FormElement } from "../../../components/ui/Form"

export type TaskFilters = {
  page: number
  limit?: number
  status?: string
  title?: string
  teamId?: string
  projectId?: string
  initiativeId?: string
  fromDate?: string | null
  untilDate?: string | null
  portfolioUnit?: string
  taskType?: string
}

type TasksListProps = {
  children: ReactNode | ReactNode[]
  setFilters: Dispatch<SetStateAction<TaskFilters>>
  filters: TaskFilters
  charts?: boolean
} & BasicPageProps

const TasksList = ({
  children,
  filters,
  setFilters,
  charts = false,
  ...props
}: TasksListProps) => {
  const { t } = useTranslation(["tasks"])
  const { register, handleSubmit } = useForm()
  const { me } = useContext(MeContext)
  const company = me?.currentCompany
  const companySlug = company?.slug

  const taskTabs = [
    {
      label: t("tabs.list"),
      to: `/companies/${companySlug}/tasks`,
    },
    {
      label: t("tabs.charts"),
      to: `/companies/${companySlug}/tasks/charts`,
    },
  ]

  const projects = company?.projects
  const initiatives = company?.initiatives
  const teams = company?.teams

  const handleTaskSearch = (data: FieldValues) => {
    const normalizedData = Object.keys(data).reduce((acc, key) => {
      if (data[key].length > 0) return { ...acc, [key]: data[key] }
      return acc
    }, {})
    setFilters({ ...filters, ...normalizedData, title: data.title })
  }

  return (
    <BasicPage {...props}>
      {taskTabs && (
        <Box
          sx={{
            mt: 2,
            mb: 6,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <Tabs
            tabs={taskTabs}
            currentPath={charts ? taskTabs[1].to : taskTabs[0].to}
          />
        </Box>
      )}
      <form onSubmit={handleSubmit(handleTaskSearch)}>
        <FormGroup sx={{ marginBottom: 8 }}>
          <Grid container spacing={5}>
            <FormElement>
              <InputLabel htmlFor="title">{t("list.form.search")}</InputLabel>
              <Input {...register("title")} defaultValue={filters.title} />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="taskType">
                {t("list.form.taskType")}
              </InputLabel>
              <Input {...register("taskType")} defaultValue={filters.title} />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="fromDate" shrink>
                {t("list.form.fromDate")}
              </InputLabel>
              <Input
                type="date"
                defaultValue={filters.fromDate}
                {...register("fromDate")}
              />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="untilDate" shrink>
                {t("list.form.untilDate")}
              </InputLabel>
              <Input
                type="date"
                defaultValue={filters.untilDate}
                {...register("untilDate")}
              />
            </FormElement>
            <FormElement>
              <InputLabel>{t("list.form.portfolioUnit")}</InputLabel>
              <Input
                {...register("portfolioUnit")}
                defaultValue={filters.portfolioUnit}
              />
            </FormElement>
            <FormElement>
              <InputLabel
                htmlFor="status"
                sx={{ backgroundColor: "white" }}
                shrink
              >
                {t("list.form.status.title")}
              </InputLabel>
              <Select
                native
                {...register("status")}
                defaultValue={filters.status}
              >
                <option value="">{t("list.form.common.placeholder")}</option>
                <option value="all">{t("list.form.status.all")}</option>
                <option value="not_finished">{t("filter.status_open")}</option>
                <option value="finished">{t("filter.statusFinished")}</option>
              </Select>
            </FormElement>
            <FormElement>
              <InputLabel
                htmlFor="initiativeId"
                sx={{ backgroundColor: "white" }}
                shrink
              >
                {t("list.form.initiativeId")}
              </InputLabel>
              <Select
                native
                {...register("initiativeId")}
                defaultValue={filters.initiativeId}
              >
                <option value="">{t("list.form.common.placeholder")}</option>
                {initiatives?.map((initiative, index) => (
                  <option
                    value={initiative.id}
                    key={`${initiative.id}--${index}`}
                  >
                    {initiative.name}
                  </option>
                ))}
              </Select>
            </FormElement>
            <FormElement>
              <InputLabel
                htmlFor="projectId"
                sx={{ backgroundColor: "white" }}
                shrink
              >
                {t("list.form.projectId")}
              </InputLabel>
              <Select
                native
                {...register("projectId")}
                defaultValue={filters.projectId}
              >
                <option value="">{t("list.form.common.placeholder")}</option>
                {projects?.map((project, index) => (
                  <option value={project.id} key={`${project.id}--${index}`}>
                    {project.name}
                  </option>
                ))}
              </Select>
            </FormElement>
            <FormElement>
              <InputLabel
                htmlFor="teamId"
                sx={{ backgroundColor: "white" }}
                shrink
              >
                {t("list.form.teamId")}
              </InputLabel>
              <Select
                native
                {...register("teamId")}
                defaultValue={filters.teamId}
              >
                <option value="">{t("list.form.common.placeholder")}</option>
                {teams?.map((team, index) => (
                  <option value={team.id} key={`${team.id}--${index}`}>
                    {team.name}
                  </option>
                ))}
              </Select>
            </FormElement>
            <FormElement>
              <Button sx={{ alignSelf: "flex-start" }} type="submit">
                <SearchIcon fontSize="large" color="primary" />
                {t("list.form.button.label")}
              </Button>
            </FormElement>
          </Grid>
        </FormGroup>
      </form>
      {children}
    </BasicPage>
  )
}

export default TasksList

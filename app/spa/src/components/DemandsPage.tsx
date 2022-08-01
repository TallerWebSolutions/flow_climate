import {
  FormGroup,
  FormControl,
  InputLabel,
  Input,
  Select,
  Grid,
  Button,
  Box,
} from "@mui/material"
import SearchIcon from "@mui/icons-material/Search"
import { useTranslation } from "react-i18next"
import { FieldValues, useForm } from "react-hook-form"
import { Dispatch, ReactNode, SetStateAction, useContext } from "react"
import { DemandsList } from "../modules/demand/demand.types"
import { MeContext } from "../contexts/MeContext"
import BasicPage, { BasicPageProps } from "./BasicPage"
import { Tabs } from "./Tabs"
import { useLocation } from "react-router-dom"

const FormElement = ({ children }: { children: ReactNode }) => (
  <Grid item xs={4}>
    <FormControl sx={{ width: "100%" }}>{children}</FormControl>
  </Grid>
)

export type DemandsSearchDTO = {
  demandsTableData: DemandsList
}

type DemandPageProps = {
  children: ReactNode | ReactNode[]
  filters: FieldValues
  setFilters?: Dispatch<SetStateAction<FieldValues>>
} & BasicPageProps

const DemandsPage = ({
  children,
  loading,
  breadcrumbsLinks,
  filters,
}: DemandPageProps) => {
  const { t } = useTranslation("demands")
  const { me } = useContext(MeContext)
  const company = me?.currentCompany
  const companySlug = company?.slug

  const { register } = useForm()

  const initiatives = me?.currentCompany?.initiatives
  const projects = me?.currentCompany?.projects
  const teams = me?.currentCompany?.teams
  const { pathname } = useLocation()

  const sanitizedFilters = Object.keys(filters).reduce(
    (acc, key) =>
      filters[key] && filters[key] !== "null"
        ? { ...acc, [key]: filters[key] }
        : acc,
    {}
  )
  const urlSearchParams = new URLSearchParams(sanitizedFilters).toString()

  const demandsTabs = [
    {
      label: t("list.title"),
      to: `/companies/${companySlug}/demands?${urlSearchParams}`,
    },
    {
      label: t("charts.title"),
      to: `/companies/${companySlug}/demands/demands_charts?${urlSearchParams}`,
    },
  ]

  return (
    <BasicPage
      title={t("list.title")}
      loading={loading}
      breadcrumbsLinks={breadcrumbsLinks}
    >
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
          tabs={demandsTabs}
          currentPath={`${pathname}?${new URLSearchParams(filters).toString()}`}
        />
      </Box>

      <form>
        <FormGroup>
          <Grid container spacing={5}>
            <FormElement>
              <InputLabel htmlFor="searchText">
                {t("list.form.search")}
              </InputLabel>
              <Input
                {...register("searchText")}
                defaultValue={filters.searchText}
              />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="startDate" shrink>
                {t("list.form.startDate")}
              </InputLabel>
              <Input
                type="date"
                defaultValue={filters.startDate}
                {...register("startDate")}
              />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="endDate" shrink>
                {t("list.form.endDate")}
              </InputLabel>
              <Input
                type="date"
                defaultValue={filters.endDate}
                {...register("endDate")}
              />
            </FormElement>
            <FormElement>
              <InputLabel
                htmlFor="demandStatus"
                sx={{ backgroundColor: "white" }}
                shrink
              >
                {t("list.form.status.title")}
              </InputLabel>
              <Select
                native
                {...register("demandStatus")}
                defaultValue={filters.demandStatus}
              >
                <option value="">{t("list.form.common.placeholder")}</option>
                <option value="ALL_DEMANDS">{t("list.form.status.all")}</option>
                <option value="NOT_COMMITTED">
                  {t("list.form.status.notCommitted")}
                </option>
                <option value="WORK_IN_PROGRESS">
                  {t("list.form.status.wip")}
                </option>
                <option value="DELIVERED_DEMANDS">
                  {t("list.form.status.delivered")}
                </option>
                <option value="NOT_STARTED">
                  {t("list.form.status.notStarted")}
                </option>
                <option value="DISCARDED_DEMANDS">
                  {t("list.form.status.discarded")}
                </option>
                <option value="NOT_DISCARDED_DEMANDS">
                  {t("list.form.status.notDiscarded")}
                </option>
              </Select>
            </FormElement>
            {!!initiatives?.length && (
              <FormElement>
                <InputLabel
                  htmlFor="initiative"
                  sx={{ backgroundColor: "white" }}
                  shrink
                >
                  {t("list.form.initiative")}
                </InputLabel>
                <Select
                  native
                  {...register("initiative")}
                  defaultValue={filters.initiative}
                >
                  <option value="">{t("list.form.common.placeholder")}</option>
                  {initiatives.map((initiative, index) => (
                    <option
                      value={initiative.id}
                      key={`${initiative.id}--${index}`}
                    >
                      {initiative.name}
                    </option>
                  ))}
                </Select>
              </FormElement>
            )}
            {!!projects?.length && (
              <FormElement>
                <InputLabel
                  htmlFor="project"
                  sx={{ backgroundColor: "white", padding: 1 }}
                  shrink
                >
                  {t("list.form.project")}
                </InputLabel>
                <Select
                  native
                  {...register("project")}
                  defaultValue={filters.project}
                >
                  <option value="">{t("list.form.common.placeholder")}</option>
                  {projects.map((project, index) => (
                    <option value={project.id} key={`${project.id}--${index}`}>
                      {project.name}
                    </option>
                  ))}
                </Select>
              </FormElement>
            )}
            {!!teams?.length && (
              <FormElement>
                <InputLabel
                  htmlFor="team"
                  sx={{ backgroundColor: "white", padding: 1 }}
                  shrink
                >
                  {t("list.form.team")}
                </InputLabel>
                <Select
                  native
                  {...register("team")}
                  defaultValue={filters.team}
                >
                  <option value="">{t("list.form.common.placeholder")}</option>
                  {teams.map((team, index) => (
                    <option value={team.id} key={`${team.id}--${index}`}>
                      {team.name}
                    </option>
                  ))}
                </Select>
              </FormElement>
            )}
            <FormElement>
              <InputLabel
                htmlFor="demandType"
                sx={{ backgroundColor: "white", padding: 1 }}
                shrink
              >
                {t("list.form.demandType")}
              </InputLabel>
              <Select
                native
                {...register("demandType")}
                defaultValue={filters.demandType}
              >
                <option value="">{t("list.form.common.placeholder")}</option>
                {company?.workItemTypes?.map((type, index) => (
                  <option value={type.name} key={`${type.id}--${index}`}>
                    {type.name}
                  </option>
                ))}
              </Select>
            </FormElement>
            <FormElement>
              <Button sx={{ alignSelf: "flex-start" }} type="submit">
                <SearchIcon fontSize="large" color="primary" />
              </Button>
            </FormElement>
          </Grid>
        </FormGroup>
      </form>
      {children}
    </BasicPage>
  )
}

export default DemandsPage

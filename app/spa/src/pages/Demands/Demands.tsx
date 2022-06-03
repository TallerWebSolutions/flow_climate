import {
  FormGroup,
  FormControl,
  InputLabel,
  Input,
  Select,
  Grid,
  Button,
} from "@mui/material"
import SearchIcon from "@mui/icons-material/Search"
import { useTranslation } from "react-i18next"
import { FieldValues, useForm } from "react-hook-form"
import { gql, useQuery } from "@apollo/client"
import { ReactNode, useContext, useState } from "react"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/ui/Table"
import { MeContext } from "../../contexts/MeContext"
import { DemandsList } from "../../modules/demand/demand.types"

const DEMANDS_QUERY = gql`
  query DemandsSearch(
    $orderField: String!
    $pageNumber: Int
    $perPage: Int
    $project: Int
    $startDate: ISO8601Date
    $endDate: ISO8601Date
    $demandStatus: DemandStatuses
    $initiative: Int
    $team: Int
    $searchText: String
    $sortDirection: SortDirection
  ) {
    demandsList(
      searchOptions: {
        pageNumber: $pageNumber
        perPage: $perPage
        projectId: $project
        startDate: $startDate
        endDate: $endDate
        demandStatus: $demandStatus
        iniciativeId: $initiative
        teamId: $team
        searchText: $searchText
        orderField: $orderField
        sortDirection: $sortDirection
      }
    ) {
      demands {
        id
        externalId
        demandTitle
        createdDate
        endDate
      }
      lastPage
      totalCount
      totalPages
    }
  }
`

const FormElement = ({ children }: { children: ReactNode }) => (
  <Grid item xs={4}>
    <FormControl sx={{ width: "100%" }}>{children}</FormControl>
  </Grid>
)

type DemandsSearchDTO = {
  demandsList: DemandsList
}

const Demands = () => {
  const [pageNumber, setPageNumber] = useState(1)
  const perPage = 10
  const sortDirection = "DESC"
  const orderField = "end_date"
  const [filters, setFilters] = useState<FieldValues>({
    perPage,
    sortDirection,
    orderField,
    pageNumber,
  })
  const { data, loading } = useQuery<DemandsSearchDTO>(DEMANDS_QUERY, {
    variables: filters,
  })
  const demandsCount = data?.demandsList.totalCount || 0
  const { me } = useContext(MeContext)
  const { t } = useTranslation("demands")
  const { register, handleSubmit } = useForm()
  const tableHeader = [
    t("table.header.id"),
    t("table.header.title"),
    t("table.header.createdDate"),
    t("table.header.deliveryDate"),
    t("table.header.timeToFinish"),
  ]
  const tableRows =
    data?.demandsList.demands.map((demand) => [
      demand.externalId || "",
      demand.demandTitle || "",
      demand.createdDate || "",
      demand.endDate || "",
      demand.leadtime || 0,
    ]) || []
  const initiatives = me?.currentCompany?.initiatives
  const projects = me?.currentCompany?.projects
  const teams = me?.currentCompany?.teams
  const breadcrumbsLinks = [{ name: "To" }, { name: "be" }, { name: "done" }]

  return (
    <BasicPage
      title={t("list.title")}
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
    >
      <form
        onSubmit={handleSubmit((formFilters) =>
          setFilters({ ...filters, ...formFilters })
        )}
      >
        <FormGroup>
          <Grid container spacing={5}>
            <FormElement>
              <InputLabel htmlFor="search">{t("list.form.search")}</InputLabel>
              <Input {...register("search")} />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="startDate" shrink>
                {t("list.form.startDate")}
              </InputLabel>
              <Input type="date" {...register("startDate")} />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="endDate" shrink>
                {t("list.form.endDate")}
              </InputLabel>
              <Input type="date" {...register("endDate")} />
            </FormElement>
            <FormElement>
              <InputLabel
                htmlFor="status"
                sx={{ backgroundColor: "white" }}
                shrink
              >
                {t("list.form.status")}
              </InputLabel>
              <Select native {...register("status")}>
                <option value="">{t("list.form.status.placeholder")}</option>
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
            {initiatives && (
              <FormElement>
                <InputLabel
                  htmlFor="initiative"
                  sx={{ backgroundColor: "white" }}
                  shrink
                >
                  {t("list.form.initiative")}
                </InputLabel>
                <Select native {...register("initiative")}>
                  <option value="">
                    {t("list.form.initiative.placeholder")}
                  </option>
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
            {projects && (
              <FormElement>
                <InputLabel
                  htmlFor="project"
                  sx={{ backgroundColor: "white", padding: 1 }}
                  shrink
                >
                  {t("list.form.project")}
                </InputLabel>
                <Select native {...register("project")}>
                  <option value="">{t("list.form.project.placeholder")}</option>
                  {projects.map((project, index) => (
                    <option value={project.id} key={`${project.id}--${index}`}>
                      {project.name}
                    </option>
                  ))}
                </Select>
              </FormElement>
            )}
            {teams && (
              <FormElement>
                <InputLabel
                  htmlFor="team"
                  sx={{ backgroundColor: "white", padding: 1 }}
                  shrink
                >
                  {t("list.form.team")}
                </InputLabel>
                <Select native {...register("team")}>
                  <option disabled>{t("list.form.team.placeholder")}</option>
                  {teams.map((team, index) => (
                    <option value={team.id} key={`${team.id}--${index}`}>
                      {team.name}
                    </option>
                  ))}
                </Select>
              </FormElement>
            )}
            <FormElement>
              <Button sx={{ alignSelf: "flex-start" }} type="submit">
                <SearchIcon fontSize="large" color="primary" />
              </Button>
            </FormElement>
          </Grid>
        </FormGroup>
      </form>
      <Table
        title={t("list.table.title", { demandsCount })}
        headerCells={tableHeader}
        rows={tableRows}
        pagination={{
          count: demandsCount,
          rowsPerPage: perPage,
          page: pageNumber,
          onPageChange: (_, newPage: number) => setPageNumber(newPage),
        }}
      />
    </BasicPage>
  )
}

export default Demands

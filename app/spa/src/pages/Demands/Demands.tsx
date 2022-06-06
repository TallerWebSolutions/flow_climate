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
import { CSVLink } from "react-csv"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/ui/Table"
import { MeContext } from "../../contexts/MeContext"
import { Demand, DemandsList } from "../../modules/demand/demand.types"
import { formatDate } from "../../lib/date"

const DEMANDS_QUERY = gql`
  query DemandsSearch(
    $orderField: String!
    $searchText: String
    $pageNumber: Int
    $perPage: Int
    $project: ID
    $startDate: ISO8601Date
    $endDate: ISO8601Date
    $demandStatus: DemandStatuses
    $initiative: ID
    $team: ID
    $sortDirection: SortDirection
  ) {
    demandsTableData: demandsList(
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
      ...demandsList
    }
    demandsCsvData: demandsList(
      searchOptions: {
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
      ...demandsList
    }
  }

  fragment demandsList on DemandsList {
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
`

const FormElement = ({ children }: { children: ReactNode }) => (
  <Grid item xs={3}>
    <FormControl sx={{ width: "100%" }}>{children}</FormControl>
  </Grid>
)

type DemandsSearchDTO = {
  demandsTableData: DemandsList
  demandsCsvData: DemandsList
}

const Demands = () => {
  const [pageNumber, setPageNumber] = useState(0)
  const perPage = 10
  const sortDirection = "DESC"
  const orderField = "end_date"
  const searchText = ""
  const [filters, setFilters] = useState<FieldValues>({
    searchText,
    perPage,
    sortDirection,
    orderField,
    pageNumber,
    startDate: "1900-01-01",
    endDate: formatDate({
      date: new Date().toISOString(),
      format: "yyyy-MM-dd",
    }),
  })
  const { data, loading } = useQuery<DemandsSearchDTO>(DEMANDS_QUERY, {
    variables: filters,
  })
  const demandsCount = data?.demandsTableData.totalCount || 0
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
  const normalizeTableRow = (demand: Demand) => [
    demand.externalId || "",
    demand.demandTitle || "",
    demand.createdDate || "",
    demand.endDate || "",
    demand.leadtime || 0,
  ]

  const tableRows = data?.demandsTableData.demands.map(normalizeTableRow) || []

  const csvRows = data?.demandsCsvData.demands.map(normalizeTableRow) || []

  const initiatives = me?.currentCompany?.initiatives
  const projects = me?.currentCompany?.projects
  const teams = me?.currentCompany?.teams
  const breadcrumbsLinks = [
    {
      name: me?.currentCompany?.name || "",
      url: `/companies/${me?.currentCompany?.slug}`,
    },
    {
      name: t("list.title"),
    },
  ]

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
              <InputLabel htmlFor="searchText">
                {t("list.form.search")}
              </InputLabel>
              <Input {...register("searchText")} />
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
              <Select native {...register("demandStatus")}>
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
                <Select native {...register("initiative")}>
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
                <Select native {...register("project")}>
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
                <Select native {...register("team")}>
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
              <Button sx={{ alignSelf: "flex-start" }} type="submit">
                <SearchIcon fontSize="large" color="primary" />
              </Button>
            </FormElement>
          </Grid>
        </FormGroup>
      </form>
      <Button
        variant="contained"
        sx={{ a: { color: "white", textDecoration: "none" } }}
      >
        <CSVLink data={csvRows} headers={tableHeader}>
          {t("list.form.downloadCsv")}
        </CSVLink>
      </Button>
      <Table
        title={t("list.table.title", { count: demandsCount })}
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

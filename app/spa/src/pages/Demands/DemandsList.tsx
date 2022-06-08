import DemandsPage, { DemandsSearchDTO } from "../../components/DemandsPage"
import Table from "../../components/ui/Table"
import { useContext, useState } from "react"
import { gql, useQuery } from "@apollo/client"
import { Demand } from "../../modules/demand/demand.types"
import { Button } from "@mui/material"
import { CSVLink } from "react-csv"
import { useTranslation } from "react-i18next"
import { MeContext } from "../../contexts/MeContext"
import { FieldValues } from "react-hook-form"
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

const DemandsList = () => {
  const { t } = useTranslation("demands")
  const { me } = useContext(MeContext)

  const perPage = 10
  const [pageNumber, setPageNumber] = useState(0)
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

  const breadcrumbsLinks = [
    {
      name: me?.currentCompany?.name || "",
      url: `/companies/${me?.currentCompany?.slug}`,
    },
    {
      name: t("list.title"),
    },
  ]

  const normalizeTableRow = (demand: Demand) => [
    demand.externalId || "",
    demand.demandTitle || "",
    demand.createdDate || "",
    demand.endDate || "",
    demand.leadtime || 0,
  ]

  const tableHeader = [
    t("table.header.id"),
    t("table.header.title"),
    t("table.header.createdDate"),
    t("table.header.deliveryDate"),
    t("table.header.timeToFinish"),
  ]

  const demandsCount = data?.demandsTableData.totalCount || 0
  const tableRows = data?.demandsTableData.demands.map(normalizeTableRow) || []
  const csvRows = data?.demandsCsvData.demands.map(normalizeTableRow) || []

  const TableTitle = () => (
    <>
      {t("list.table.title", { count: demandsCount })}{" "}
      <Button
        variant="contained"
        sx={{ a: { color: "white", textDecoration: "none" } }}
      >
        <CSVLink data={csvRows} headers={tableHeader}>
          {t("list.form.downloadCsv")}
        </CSVLink>
      </Button>
    </>
  )

  return (
    <DemandsPage
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
      perPage={perPage}
      pageNumber={pageNumber}
      filters={filters}
      setFilters={setFilters}
    >
      <Table
        title={<TableTitle />}
        headerCells={tableHeader}
        rows={tableRows}
        pagination={{
          count: demandsCount,
          rowsPerPage: perPage,
          page: pageNumber,
          onPageChange: (_, newPage: number) => setPageNumber(newPage),
        }}
      />
    </DemandsPage>
  )
}

export default DemandsList

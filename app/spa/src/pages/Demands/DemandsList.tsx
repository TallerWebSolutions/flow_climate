import { useContext, useState } from "react"
import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { Button, Link } from "@mui/material"
import { CSVLink } from "react-csv"
import { FieldValues } from "react-hook-form"

import { Demand } from "../../modules/demand/demand.types"
import Table from "../../components/ui/Table"
import DemandsPage, { DemandsSearchDTO } from "../../components/DemandsPage"
import { MeContext } from "../../contexts/MeContext"
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
  const companySlug = me?.currentCompany?.slug

  const [filters, setFilters] = useState<FieldValues>({
    searchText: "",
    perPage: 10,
    sortDirection: "DESC",
    orderField: "end_date",
    pageNumber: 0,
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
    <Link href={`/companies/${companySlug}/demands/${demand.externalId}`}>
      {demand.externalId}
    </Link>,
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
      filters={filters}
      setFilters={setFilters}
    >
      <Table
        title={<TableTitle />}
        headerCells={tableHeader}
        rows={tableRows}
        pagination={{
          count: demandsCount,
          rowsPerPage: filters.perPage,
          page: filters.pageNumber,
          onPageChange: (_, newPage: number) =>
            setFilters((filters) => ({ ...filters, pageNumber: newPage + 1 })),
        }}
      />
    </DemandsPage>
  )
}

export default DemandsList

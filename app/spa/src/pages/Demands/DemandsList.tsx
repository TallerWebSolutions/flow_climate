import { useContext, useState } from "react"
import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { Button, Link } from "@mui/material"
import { CSVLink } from "react-csv"
import { FieldValues } from "react-hook-form"
import EditIcon from "@mui/icons-material/Edit"

import { Demand } from "../../modules/demand/demand.types"
import Table from "../../components/ui/Table"
import DemandsPage, { DemandsSearchDTO } from "../../components/DemandsPage"
import { MeContext } from "../../contexts/MeContext"
import { useSearchParams } from "react-router-dom"
import { secondsToReadbleDate } from "../../lib/date"
import DateLocale from "../../components/ui/DateLocale"

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
      leadtime
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
  const [searchParams] = useSearchParams()

  const [filters, setFilters] = useState<FieldValues>({
    initiative: searchParams.get("initiative"),
    team: searchParams.get("team"),
    project: searchParams.get("project"),
    searchText: searchParams.get("searchText"),
    demandStatus: searchParams.get("demandStatus"),
    sortDirection: "DESC",
    orderField: "end_date",
    startDate: searchParams.get("startDate"),
    endDate: searchParams.get("endDate"),
    pageNumber: searchParams.get("pageNumber"),
    perPage: 10,
  })

  const { data, loading } = useQuery<DemandsSearchDTO>(DEMANDS_QUERY, {
    variables: Object.keys(filters)
      .filter((key) => {
        return String(filters[key]).length > 0
      })
      .reduce<Record<string, string>>((acc, el) => {
        return { ...acc, [el]: filters[el] }
      }, {}),
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
    demand.createdDate ? <DateLocale time date={demand.createdDate} /> : "",
    demand.endDate ? <DateLocale time date={demand.endDate} /> : "",
    secondsToReadbleDate(demand.leadtime),
    <Link href={`/companies/${companySlug}/demands/${demand.externalId}/edit`}>
      <EditIcon />
    </Link>,
  ]

  const tableHeader = [
    t("table.header.id"),
    t("table.header.title"),
    t("table.header.createdDate"),
    t("table.header.deliveryDate"),
    t("table.header.timeToFinish"),
    t("table.header.actions"),
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

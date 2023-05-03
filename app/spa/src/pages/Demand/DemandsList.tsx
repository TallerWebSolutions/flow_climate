import { useContext, useState } from "react"
import { useTranslation } from "react-i18next"
import { gql, useLazyQuery, useMutation, useQuery } from "@apollo/client"
import {
  Avatar,
  AvatarGroup,
  Box,
  Button,
  ButtonGroup,
  CircularProgress,
  Link,
  Typography,
} from "@mui/material"
import { CSVLink } from "react-csv"
import { FieldValues } from "react-hook-form"
import EditIcon from "@mui/icons-material/Edit"
import DeleteIcon from "@mui/icons-material/Delete"
import { formatISO } from "date-fns"
import { useSearchParams, Link as RouterLink } from "react-router-dom"

import { Demand, DemandsList } from "../../modules/demand/demand.types"
import Table, { RowWithCollapse } from "../../components/ui/Table"
import DemandsPage, { DemandsSearchDTO } from "../../components/DemandsPage"
import { MeContext } from "../../contexts/MeContext"
import { secondsToReadbleDate } from "../../lib/date"
import DateLocale from "../../components/ui/DateLocale"
import { MessagesContext } from "../../contexts/MessageContext"
import Modal from "@mui/material/Modal"

const DEMAND_FRAGMENT = gql`
  fragment demandsList on DemandsList {
    demands {
      id
      externalId
      demandTitle
      createdDate
      endDate
      leadtime
      commitmentDate
      demandType
      costToProject
      effortDownstream
      effortUpstream
      demandBlocksCount
      discardedAt
      product {
        name
      }
      responsibles {
        id
        name
        user {
          id
          firstName
          lastName
          avatar {
            imageSource
          }
        }
      }
    }
    lastPage
    totalCount
    totalPages
    totalEffort
  }
`

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
    $demandType: String
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
        demandType: $demandType
      }
    ) {
      ...demandsList
    }
  }

  ${DEMAND_FRAGMENT}
`

const DEMANDS_CSV_QUERY = gql`
  query DemandsCSV(
    $orderField: String!
    $searchText: String
    $project: ID
    $startDate: ISO8601Date
    $endDate: ISO8601Date
    $demandStatus: DemandStatuses
    $initiative: ID
    $team: ID
    $sortDirection: SortDirection
    $demandType: String
  ) {
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
        demandType: $demandType
      }
    ) {
      ...demandsList
    }
  }

  ${DEMAND_FRAGMENT}
`

const DISCARD_DEMAND_MUTATION = gql`
  mutation DiscardDemand($demandId: String!) {
    discardDemand(demandId: $demandId) {
      statusMessage
    }
  }
`

const DELETE_DEMAND_MUTATION = gql`
  mutation DeleteDemand($demandId: String!) {
    deleteDemand(demandId: $demandId) {
      statusMessage
    }
  }
`

type DemandsCSVDTO = {
  demandsCsvData: DemandsList
}

type DiscardDemandType = {
  discardDemand: {
    statusMessage: string
  }
}

type DeleteDemandType = {
  deleteDemand: {
    statusMessage: string
  }
}

interface DemandOptionsModalProps {
  demandId: string
  discardedAt?: string
  onDiscardDemand: (demandId: string) => void
  onDeleteDemand: (demandId: string) => void
}

const normalizeQueryStringFilters = (filters: FieldValues) =>
  Object.keys(filters)
    .filter((key) => {
      return String(filters[key]).length > 0 && filters[key] !== "null"
    })
    .reduce<Record<string, string>>((acc, el) => {
      return { ...acc, [el]: filters[el] }
    }, {})

const DemandsListPage = () => {
  const { t } = useTranslation("demand")
  const { me } = useContext(MeContext)
  const companySlug = me?.currentCompany?.slug
  const [searchParams, setSearchParams] = useSearchParams()
  const filters: FieldValues = {
    initiative: searchParams.get("initiative"),
    team: searchParams.get("team"),
    project: searchParams.get("project"),
    searchText: searchParams.get("searchText") || "",
    demandStatus: searchParams.get("demandStatus") || "ALL_DEMANDS",
    sortDirection: "DESC",
    orderField: "end_date",
    startDate: searchParams.get("startDate"),
    endDate: searchParams.get("endDate"),
    pageNumber: Number(searchParams.get("pageNumber") || 1),
    perPage: 20,
    demandType: searchParams.get("demandType"),
  }
  const demandsQueryFilters = normalizeQueryStringFilters(filters)

  const { data, loading, variables } = useQuery<DemandsSearchDTO>(
    DEMANDS_QUERY,
    {
      variables: demandsQueryFilters,
    }
  )
  const { pushMessage } = useContext(MessagesContext)

  const [discardDemand] = useMutation<DiscardDemandType>(
    DISCARD_DEMAND_MUTATION,
    {
      update: (_, { data }) => {
        const mutationResult = data?.discardDemand.statusMessage === "SUCCESS"

        pushMessage({
          text: mutationResult
            ? t("notification.discarded_demand_message_success")
            : t("notification.discarded_demand_message_fail"),
          severity: mutationResult ? "success" : "error",
        })
      },
      refetchQueries: [
        { query: DEMANDS_QUERY, variables: demandsQueryFilters },
      ],
    }
  )

  const [deleteDemand] = useMutation<DeleteDemandType>(DELETE_DEMAND_MUTATION, {
    update: (_, { data }) => {
      const mutationResult = data?.deleteDemand.statusMessage === "SUCCESS"

      pushMessage({
        text: mutationResult
          ? t("notification.delete_demand_message_success")
          : t("notification.delete_demand_message_fail"),
        severity: mutationResult ? "success" : "error",
      })
    },
    refetchQueries: [{ query: DEMANDS_QUERY, variables: demandsQueryFilters }],
  })

  const [
    fetchCSVData,
    { data: csvData, loading: csvLoading, called: csvQueryCalled },
  ] = useLazyQuery<DemandsCSVDTO>(DEMANDS_CSV_QUERY, {
    variables: demandsQueryFilters,
  })

  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const breadcrumbsLinks = [
    {
      name: me?.currentCompany?.name || "",
      url: companyUrl,
    },
    {
      name: t("list.title"),
    },
  ]

  const onDiscardDemand = (id: String) =>
    discardDemand({ variables: { demandId: id } })

  const onDeleteDemand = (id: String) =>
    deleteDemand({
      variables: { demandId: id },
    })

  const DemandOptionsModal = ({
    demandId,
    discardedAt,
    onDiscardDemand,
    onDeleteDemand,
  }: DemandOptionsModalProps) => {
    const [isModalOpen, setIsModalOpen] = useState(false)

    const handleOnDiscardDemand = () => {
      setIsModalOpen(false)
      onDiscardDemand(demandId)
    }

    const handleOnDeleteDemand = () => {
      setIsModalOpen(false)
      onDeleteDemand(demandId)
    }

    return (
      <>
        <Button
          variant="text"
          onClick={() => {
            setIsModalOpen(true)
          }}
        >
          <DeleteIcon />
        </Button>
        <Modal open={isModalOpen} onClose={() => setIsModalOpen(false)}>
          <Box
            sx={{
              position: "absolute" as "absolute",
              p: 4,
              top: "50%",
              left: "50%",
              transform: "translate(-50%, -50%)",
              width: 680,
              height: 160,
              bgcolor: "background.paper",
              boxShadow: 24,
              justifyContent: "space-between",
              display: "flex",
              flexDirection: "column",
            }}
          >
            <Typography variant="h2" component="h2" fontSize={"1.25rem"}>
              Tem certeza que deseja excluir a demanda?
            </Typography>
            <Box
              sx={{
                alignSelf: "flex-end",
              }}
            >
              {!discardedAt && (
                <Button sx={{ marginRight: 2 }} onClick={handleOnDiscardDemand}>
                  Enviar para a lixeira
                </Button>
              )}
              <Button onClick={handleOnDeleteDemand}>
                Excluir permanentemente
              </Button>
            </Box>
          </Box>
        </Modal>
      </>
    )
  }

  const normalizeTableRow = (demand: Demand) => {
    return {
      rowInfo: [
        <Link
          href={`/companies/${companySlug}/demands/${demand.externalId}`}
          sx={{ minWidth: "75px", display: "block" }}
        >
          {demand.externalId}
        </Link>,
        demand.demandTitle || "",
        demand.demandType,
        <AvatarGroup
          max={3}
          spacing={1}
          componentsProps={{
            additionalAvatar: {
              sx: { width: "25px", height: "25px", fontSize: ".875rem" },
            },
          }}
        >
          {demand.responsibles &&
            demand.responsibles.map((responsible, index) => (
              <RouterLink
                to={`${companyUrl}/team_members/${responsible.id}`}
                style={{ textDecoration: "none" }}
              >
                <Avatar
                  key={`${responsible.name}--${index}`}
                  alt={responsible.name}
                  sx={{ width: "25px", height: "25px", fontSize: ".875rem" }}
                  src={
                    responsible.user?.avatar?.imageSource ||
                    process.env.PUBLIC_URL + "default.png"
                  }
                  children={
                    !responsible.user?.avatar?.imageSource &&
                    `${responsible.user?.firstName?.[0]}${responsible.user?.lastName?.[0]}`
                  }
                />
              </RouterLink>
            ))}
        </AvatarGroup>,
        demand.createdDate ? <DateLocale date={demand.createdDate} /> : "",
        demand.commitmentDate ? (
          <DateLocale date={demand.commitmentDate} />
        ) : (
          ""
        ),
        demand.endDate ? <DateLocale time date={demand.endDate} /> : "",
        secondsToReadbleDate(demand.leadtime),
        <ButtonGroup>
          <Button
            variant="text"
            href={`/companies/${companySlug}/demands/${demand.externalId}/edit`}
          >
            <EditIcon />
          </Button>
          <DemandOptionsModal
            demandId={demand.id}
            discardedAt={demand.discardedAt}
            onDiscardDemand={onDiscardDemand}
            onDeleteDemand={onDeleteDemand}
          />
        </ButtonGroup>,
      ],
      collapseInfo: {
        collapseHeader: [
          t("table.header.costToProject"),
          t("table.header.effortDownstream"),
          t("table.header.effortUpstream"),
          t("table.header.numberOfBlocks"),
          t("table.header.productName"),
        ],
        collapseBody: [
          "$" + demand.costToProject?.toFixed(2) || "",
          demand.effortDownstream?.toFixed(2) + " " + t("hours") || "",
          demand.effortUpstream?.toFixed(2) + " " + t("hours") || "",
          demand.demandBlocksCount || 0,
          demand.product?.name || "",
        ],
      },
    }
  }

  const normalizeCsvTableRow = (demand: Demand) => [
    demand.externalId,
    demand.demandTitle || "",
    demand.demandType,
    demand.responsibles?.map(({ name }) => name).join(", "),
    demand.createdDate,
    demand.commitmentDate,
    demand.endDate,
    demand.leadtime,
    demand.effortUpstream,
    demand.effortDownstream,
  ]

  const tableHeader = [
    "",
    t("table.header.id"),
    t("table.header.title"),
    t("table.header.demandType"),
    t("table.header.responsibles"),
    t("table.header.createdDate"),
    t("table.header.commitmentDate"),
    t("table.header.deliveryDate"),
    t("table.header.timeToFinish"),
    t("table.header.actions"),
  ]

  const tableCsvHeader = [
    t("table.header.id"),
    t("table.header.title"),
    t("table.header.demandType"),
    t("table.header.responsibles"),
    t("table.header.createdDate"),
    t("table.header.commitmentDate"),
    t("table.header.deliveryDate"),
    t("table.header.timeToFinish"),
    t("table.header.effortUpstream"),
    t("table.header.effortDownstream"),
  ]

  const demandsCount = data?.demandsTableData.totalCount || 0
  const totalEffort = data?.demandsTableData.totalEffort?.toFixed(2) || 0
  const tableRows: RowWithCollapse[] =
    data?.demandsTableData.demands.map(normalizeTableRow) || []

  const csvRows =
    csvData?.demandsCsvData.demands.map(normalizeCsvTableRow) || []

  const csvFileReady = csvQueryCalled && !csvLoading

  const TableTitle = () => (
    <>
      {t("list.table.title", { demandsCount, totalEffort })}{" "}
      <Button
        variant={csvFileReady ? "contained" : "outlined"}
        sx={{
          minWidth: "160px",
          a: { color: "white", textDecoration: "none" },
        }}
        onClick={() => !csvQueryCalled && fetchCSVData()}
        disabled={csvLoading}
        color={csvFileReady ? "success" : "secondary"}
      >
        {csvQueryCalled ? (
          csvLoading ? (
            <CircularProgress size={20} />
          ) : (
            <CSVLink
              data={csvRows}
              headers={tableCsvHeader}
              filename={`demands_${formatISO(new Date())}.csv`}
            >
              {t("list.form.downloadCsv")}
            </CSVLink>
          )
        ) : (
          t("list.form.prepareCSVFile")
        )}
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
        withCollapse={true}
        pagination={{
          count: demandsCount,
          rowsPerPage: filters.perPage,
          page: filters.pageNumber - 1,
          onPageChange: (_, newPage: number) =>
            setSearchParams({
              ...normalizeQueryStringFilters(variables || {}),
              pageNumber: String(newPage + 1),
            }),
        }}
      />
    </DemandsPage>
  )
}

export default DemandsListPage

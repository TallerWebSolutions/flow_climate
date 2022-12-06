import { useTranslation } from "react-i18next"
import { Demand } from "../demand.types"
import { Link } from "@mui/material"
import Table from "../../../components/ui/Table"
import { formatDate, secondsToReadbleDate } from "../../../lib/date"

type LatestDeliveriesTableProps = {
  baseLink: string
  demands: Demand[]
}

const LatestDeliveriesTable = ({
  baseLink,
  demands,
}: LatestDeliveriesTableProps) => {
  const { t } = useTranslation(["demands"])
  const latestDeliveriesHeaderCells = [
    t("list.deliverablesTable.demandId"),
    t("list.deliverablesTable.client"),
    t("list.deliverablesTable.product"),
    t("list.deliverablesTable.deliveryDate"),
    t("list.deliverablesTable.leadtime"),
    t("list.deliverablesTable.demandBlocks"),
  ]

  const latestDeliveriesRows = demands.map((demand) => {
    return [
      <Link
        href={`${baseLink}/demands/${demand.externalId}`}
        sx={{ color: "info.dark", textDecoration: "none" }}
      >
        {demand.externalId}
      </Link>,
      <Link
        href={`${baseLink}/projects/${demand.project?.id}`}
        sx={{ color: "info.dark", textDecoration: "none" }}
      >
        {demand.project?.name}
      </Link>,
      <Link
        href={`${baseLink}/products/${demand.product?.id}`}
        sx={{ color: "info.dark", textDecoration: "none" }}
      >
        {demand.product?.name}
      </Link>,
      demand.endDate
        ? formatDate({
            date: demand.endDate,
            format: "dd/MM/yyyy' 'HH:mm:ss",
          })
        : "",
      secondsToReadbleDate(demand.leadtime),
      demand.numberOfBlocks,
    ]
  })

  return (
    <Table
      title={t("charts_tab.project_chart_table.latest_deliveries")}
      headerCells={latestDeliveriesHeaderCells}
      rows={latestDeliveriesRows}
    />
  )
}

export default LatestDeliveriesTable

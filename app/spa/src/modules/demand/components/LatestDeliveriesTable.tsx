import { useTranslation } from "react-i18next"
import { Demand } from "../demand.types"
import { Box, Link } from "@mui/material"
import Table from "../../../components/ui/Table"
import { formatDate, secondsToReadbleDate } from "../../../lib/date"
import { useState } from "react"
import { ReadMoreButton } from "../../../components/ReadMoreButton"

type LatestDeliveriesTableProps = {
  baseLink: string
  demands: Demand[]
}

const LatestDeliveriesTable = ({
  baseLink,
  demands,
}: LatestDeliveriesTableProps) => {
  const { t } = useTranslation(["demands"])
  const [readMore, setReadMore] = useState(true)

  const latestDeliveriesHeaderCells = [
    t("list.deliverablesTable.demandId"),
    t("list.deliverablesTable.project"),
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
        href={`${baseLink}/products/${demand.product?.slug}`}
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
      demand.demandBlocksCount,
    ]
  })

  return (
    <Box
      sx={{
        position: "relative",
        height: readMore ? "586px" : "auto",
        overflow: readMore ? "hidden" : "",
      }}
    >
      <Table
        title={t("list.deliverablesTable.latestDeliveries")}
        headerCells={latestDeliveriesHeaderCells}
        rows={latestDeliveriesRows}
      />
      {readMore && (
        <ReadMoreButton handleDisplayPostContent={() => setReadMore(false)} />
      )}
    </Box>
  )
}

export default LatestDeliveriesTable

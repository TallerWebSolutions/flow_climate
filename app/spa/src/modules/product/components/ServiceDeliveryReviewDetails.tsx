import {
  Paper,
  Table,
  TableCell,
  TableContainer,
  TableRow,
} from "@mui/material"
import { useTranslation } from "react-i18next"

import { ServiceDeliveryReview } from "../product.types"
import { secondsToDays } from "../../../lib/date"

const ServiceDeliveryReviewDetails = ({
  review,
}: ServiceDeliveryReviewDetailsProps) => {
  const { t } = useTranslation("serviceDeliveryReview")

  return (
    <TableContainer component={Paper} sx={{ background: "white", marginY: 4 }}>
      <Table>
        <TableRow>
          <TableCell>{t("table.revisionDate")}</TableCell>
          <TableCell>{review.meetingDate}</TableCell>
        </TableRow>
        <TableRow>
          <TableCell>{t("table.demands")}</TableCell>
          <TableCell>{review.demandsCount}</TableCell>
        </TableRow>
        <TableRow>
          <TableCell>{t("table.bugs")}</TableCell>
          <TableCell>{review.bugsCount}</TableCell>
        </TableRow>
        <TableRow>
          <TableCell>{t("table.discarded")}</TableCell>
          <TableCell>{review.discardedCount}</TableCell>
        </TableRow>
        <TableRow>
          <TableCell>{t("table.leadtime")}</TableCell>
          <TableCell>{secondsToDays(review.demandsLeadTimeP80 || 0)}</TableCell>
        </TableRow>
        <TableRow>
          <TableCell>{t("table.longestStage")}</TableCell>
          <TableCell>
            {review.longestStageName} ({secondsToDays(review.longestStageTime)})
          </TableCell>
        </TableRow>
      </Table>
    </TableContainer>
  )
}

type ServiceDeliveryReviewDetailsProps = {
  review: ServiceDeliveryReview
}

export default ServiceDeliveryReviewDetails

import {
  Button,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableFooter,
  TableHead,
  TableRow,
} from "@mui/material"
import { ServiceDeliveryReview } from "../product.types"
import { useTranslation } from "react-i18next"

const ServiceDeliveryReviewActions = ({
  review,
}: ServiceDeliveryReviewActionsProps) => {
  const { t } = useTranslation("serviceDeliveryReview")

  return (
    <TableContainer
      component={Paper}
      sx={{ marginY: 4, backgroundColor: "white" }}
    >
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>{t("actionItems.id")}</TableCell>
            <TableCell>{t("actionItems.actionType")}</TableCell>
            <TableCell>{t("actionItems.createdAt")}</TableCell>
            <TableCell>{t("actionItems.responsible")}</TableCell>
            <TableCell>{t("actionItems.deadline")}</TableCell>
            <TableCell>{t("actionItems.doneDate")}</TableCell>
            <TableCell>{t("actionItems.description")}</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {review.serviceDeliveryReviewActionItems?.map((actionItem, index) => (
            <TableRow key={`${actionItem.id}--${index}`}>
              <TableCell>{actionItem.id}</TableCell>
              <TableCell>{actionItem.actionType}</TableCell>
              <TableCell>{actionItem.createdAt}</TableCell>
              <TableCell>{actionItem.membership?.teamMemberName}</TableCell>
              <TableCell>{actionItem.deadline}</TableCell>
              <TableCell>{actionItem.doneDate}</TableCell>
              <TableCell>{actionItem.description}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  )
}

type ServiceDeliveryReviewActionsProps = {
  review: ServiceDeliveryReview
}

export default ServiceDeliveryReviewActions

import { gql, useQuery } from "@apollo/client"
import { Table, TableBody, TableCell, TableHead, TableRow } from "@mui/material"
import ArrowDropDownIcon from "@mui/icons-material/ArrowDropDown"
import ArrowDropUpIcon from "@mui/icons-material/ArrowDropUp"
import { useTranslation } from "react-i18next"

import type { ServiceDeliveryReview } from "../product.types"
import { Link, useParams } from "react-router-dom"

type ServiceDeliveryReviewTableProps = {
  productId: string
}

const ServiceDeliveryReviewTable = ({
  productId,
}: ServiceDeliveryReviewTableProps) => {
  const params = useParams()
  const { t } = useTranslation("serviceDeliveryReview")
  const { data } = useQuery<ServiceDeliveryReviewDTO>(
    SERVICE_DELIVERY_REVIEW_TABLE_QUERY,
    { variables: { productId } }
  )
  const productPath = `/companies/${params.companySlug}/products/${params.productSlug}`

  return (
    <Table>
      <TableHead>
        <TableRow
          sx={{
            borderBottom: "1px solid",
            borderBottomColor: "grey.200",
          }}
        >
          <TableCell>{t("table.revisionDate")}</TableCell>
          <TableCell>{t("table.slaToPull")}</TableCell>
          <TableCell>{t("table.expediteLate")}</TableCell>
          <TableCell>{t("table.leadtime")}</TableCell>
          <TableCell>{t("table.quality")}</TableCell>
        </TableRow>
      </TableHead>
      <TableBody>
        {data?.serviceDeliveryReviews.map((sdr) => {
          const delayedExpediteBottomThreshold =
            sdr?.delayedExpediteBottomThreshold
          const delayedExpediteTopThreshold = sdr?.delayedExpediteTopThreshold
          const leadTimeBottomThreshold = sdr?.leadTimeBottomThreshold
          const leadTimeTopThreshold = sdr?.leadTimeTopThreshold
          const qualityBottomThreshold = sdr?.qualityBottomThreshold
          const qualityTopThreshold = sdr?.qualityTopThreshold
          return (
            <TableRow
              sx={{
                borderBottom: "1px solid",
                borderBottomColor: "grey.200",
              }}
            >
              <TableCell>
                <Link to={`${productPath}/service_delivery_reviews/${sdr.id}`}>
                  {sdr?.meetingDate}
                </Link>
              </TableCell>
              <TableCell>{sdr?.expediteMaxPullTimeSla}</TableCell>
              <TableCell>
                <ArrowDropDownIcon
                  sx={{ position: "relative", top: "5px" }}
                  color={"error"}
                />
                {delayedExpediteBottomThreshold}% -{" "}
                {delayedExpediteTopThreshold}%
                <ArrowDropUpIcon
                  sx={{ position: "relative", top: "7px" }}
                  color={"success"}
                />
              </TableCell>
              <TableCell>
                <ArrowDropDownIcon
                  sx={{ position: "relative", top: "5px" }}
                  color={"error"}
                />
                {leadTimeBottomThreshold}% - {leadTimeTopThreshold}%
                <ArrowDropUpIcon
                  sx={{ position: "relative", top: "7px" }}
                  color={"success"}
                />
              </TableCell>
              <TableCell>
                <ArrowDropDownIcon
                  sx={{ position: "relative", top: "5px" }}
                  color={"error"}
                />
                {qualityBottomThreshold}% - {qualityTopThreshold}%
                <ArrowDropUpIcon
                  sx={{ position: "relative", top: "7px" }}
                  color={"success"}
                />
              </TableCell>
            </TableRow>
          )
        })}
      </TableBody>
    </Table>
  )
}

export default ServiceDeliveryReviewTable

type ServiceDeliveryReviewDTO = {
  serviceDeliveryReviews: ServiceDeliveryReview[]
}

export const SERVICE_DELIVERY_REVIEW_TABLE_QUERY = gql`
  query ServiceDeliveryReviewTableQuery($productId: ID!) {
    serviceDeliveryReviews(productId: $productId) {
      id
      delayedExpediteBottomThreshold
      delayedExpediteTopThreshold
      expediteMaxPullTimeSla
      leadTimeBottomThreshold
      leadTimeTopThreshold
      meetingDate
      qualityBottomThreshold
      qualityTopThreshold
    }
  }
`

import { gql, useQuery } from "@apollo/client"
import { Table, TableBody, TableCell, TableHead, TableRow } from "@mui/material"
import ArrowDropDownIcon from '@mui/icons-material/ArrowDropDown';
import ArrowDropUpIcon from '@mui/icons-material/ArrowDropUp';
import { useTranslation } from "react-i18next";
import type { ServiceDeliveryReview } from '../product.types'

type ServiceDeliveryReviewTableProps = {
    productId: string
}

const ServiceDeliveryReviewTable = ({ productId }: ServiceDeliveryReviewTableProps) => {
    const { t } = useTranslation("serviceDeliveryReview")
    const { data, loading } = useQuery<ServiceDeliveryReviewDTO>(SERVICE_DELIVERY_REVIEW_TABLE_QUERY, {
        variables: { productId },
    })

    return (
        <>
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
                    {!loading && data?.serviceDeliveryReview && data?.serviceDeliveryReview.map((sdr: any) => {
                        const delayedExpediteBottomThreshold = sdr?.delayedExpediteBottomThreshold * 10
                        const delayedExpediteTopThreshold = sdr?.delayedExpediteTopThreshold * 10
                        const leadTimeBottomThreshold = sdr?.leadTimeBottomThreshold * 10
                        const leadTimeTopThreshold = sdr?.leadTimeTopThreshold * 10
                        const qualityBottomThreshold = sdr?.qualityBottomThreshold * 10
                        const qualityTopThreshold = sdr?.qualityTopThreshold * 10
                        return (
                        <TableRow
                            sx={{
                                borderBottom: "1px solid",
                                borderBottomColor: "grey.200",
                            }}
                        >
                            <TableCell>
                                {sdr?.meetingDate}
                            </TableCell>
                            <TableCell>
                                {sdr?.expediteMaxPullTimeSla}
                            </TableCell>
                            <TableCell>
                                <ArrowDropDownIcon sx={{ position: 'relative', top: '5px' }} color={"error"} />
                                {delayedExpediteBottomThreshold}% - {delayedExpediteTopThreshold}%
                                <ArrowDropUpIcon sx={{ position: 'relative', top: '7px' }} color={"success"} />
                            </TableCell>
                            <TableCell>
                                <ArrowDropDownIcon sx={{ position: 'relative', top: '5px' }} color={"error"} />
                                {leadTimeBottomThreshold}% - {leadTimeTopThreshold}%
                                <ArrowDropUpIcon sx={{ position: 'relative', top: '7px' }} color={"success"} />
                            </TableCell>
                            <TableCell>
                                <ArrowDropDownIcon sx={{ position: 'relative', top: '5px' }} color={"error"} />
                                {qualityBottomThreshold}% - {qualityTopThreshold}%
                                <ArrowDropUpIcon sx={{ position: 'relative', top: '7px' }} color={"success"} />
                            </TableCell>
                        </TableRow>
                    )})}
                </TableBody>
            </Table>
        </>
    )
}

export default ServiceDeliveryReviewTable

type ServiceDeliveryReviewDTO = {
    serviceDeliveryReview: ServiceDeliveryReview[]
}

export const SERVICE_DELIVERY_REVIEW_TABLE_QUERY = gql`
  query ServiceDeliveryReviewTableQuery($productId: ID!) {
    serviceDeliveryReview(productId: $productId) {
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
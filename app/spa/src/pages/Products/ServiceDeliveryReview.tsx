import { gql, useQuery } from "@apollo/client"
import ProductDetails from "../../modules/product/components/ProductDetails"
import { useParams } from "react-router-dom"
import { Button } from "@mui/material"
import { useState } from "react"
import { useTranslation } from "react-i18next"
import ServiceDeliveryReviewModal from "../../modules/product/components/ServiceDeliveryReviewModal"

const ServiceDeliveryReview = () => {
    const [open, setOpen] = useState<boolean>(false)
    const params = useParams()
    const { t } = useTranslation("serviceDeliveryReview")
    const productSlug = params.productSlug || ""
    const companySlug = params.companySlug || ""

    const handleOpen = () => setOpen(true);
    const handleClose = () => setOpen(false);

    const { data, loading } = useQuery<any>(
        PRODUCT_RISK_REVIEWS_PAGE_QUERY,
        {
            variables: { productSlug },
        }
    )

    const product = data?.product

    return !!product ? (
        <ProductDetails product={product} loading={loading}>
            <Button
                variant="contained"
                sx={{ marginY: 2 }}
                onClick={handleOpen}
            >
                {t("serviceDeliveryReview.new")}
            </Button>
            <ServiceDeliveryReviewModal
                open={open}
                handleClose={handleClose}
                productSlug={productSlug}
                companySlug={companySlug}
            />
        </ProductDetails>
    ) : null
}

export default ServiceDeliveryReview

const PRODUCT_RISK_REVIEWS_PAGE_QUERY = gql`
  query ProductRiskReviewsPage($productSlug: String!) {
        product(slug: $productSlug) {
        id
        riskReviews {
            id
            leadTimeOutlierLimit
            meetingDate
            monthlyAvgBlockedTime
            weeklyAvgBlockedTime
            createdAt
        }
        ...productDetails
        }
    }
    ${ProductDetails.fragments}
`
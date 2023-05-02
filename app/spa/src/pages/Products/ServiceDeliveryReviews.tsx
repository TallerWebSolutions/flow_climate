import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"
import { Box, Button } from "@mui/material"
import { useState } from "react"
import { useTranslation } from "react-i18next"

import ProductDetails from "../../modules/product/components/ProductDetails"
import ServiceDeliveryReviewModal from "../../modules/product/components/ServiceDeliveryReviewModal"
import ServiceDeliveryReviewTable from "../../modules/product/components/ServiceDeliveryReviewTable"

const ServiceDeliveryReviews = () => {
  const [open, setOpen] = useState<boolean>(false)
  const params = useParams()
  const { t } = useTranslation("serviceDeliveryReview")
  const productSlug = params.productSlug || ""

  const handleOpen = () => setOpen(true)
  const handleClose = () => setOpen(false)

  const { data, loading } = useQuery<any>(PRODUCT_DELIVERY_REVIEW_QUERY, {
    variables: { productSlug },
  })

  const product = data?.product

  return !!product ? (
    <ProductDetails product={product} loading={loading}>
      <Box sx={{ marginY: 2 }}>
        <Button variant="contained" onClick={handleOpen}>
          {t("serviceDeliveryReview.new")}
        </Button>
        <ServiceDeliveryReviewModal
          open={open}
          handleClose={handleClose}
          productSlug={productSlug}
          productId={product?.id}
        />
      </Box>
      <ServiceDeliveryReviewTable productId={product?.id} />
    </ProductDetails>
  ) : null
}

export default ServiceDeliveryReviews

const PRODUCT_DELIVERY_REVIEW_QUERY = gql`
  query ProductDeliveryReviewQuery($productSlug: String!) {
    product(slug: $productSlug) {
      id
      ...productDetails
    }
  }
  ${ProductDetails.fragments}
`

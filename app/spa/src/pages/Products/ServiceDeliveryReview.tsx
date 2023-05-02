import { gql, useQuery } from "@apollo/client"
import BasicPage from "../../components/BasicPage"
import { ServiceDeliveryReview } from "../../modules/product/product.types"
import { useTranslation } from "react-i18next"
import { useContext } from "react"
import { MeContext } from "../../contexts/MeContext"
import { useParams } from "react-router-dom"

const ServiceDeliveryReviewPage = () => {
  const { t } = useTranslation("serviceDeliveryReview")
  const params = useParams()

  const reviewId = params.reviewId
  const { data, loading } = useQuery<ServiceDeliveryReviewDTO>(
    SERVICE_DELIVERY_REVIEW_QUERY,
    { variables: { reviewId } }
  )
  const { me } = useContext(MeContext)

  const review = data?.serviceDeliveryReview
  const product = review?.product
  const productSlug = product?.slug
  const productName = product?.name || ""
  const company = me?.currentCompany
  const companyName = company?.name || ""
  const companySlug = company?.slug
  const reviewTitle = t("title", { date: review?.meetingDate })

  const breadcrumbsLinks = [
    { name: companyName, url: `/companies/${companySlug}` },
    {
      name: t("products"),
      url: `/companies/${companySlug}/products`,
    },
    {
      name: productName,
      url: `/companies/${companySlug}/products/${productSlug}`,
    },
    { name: reviewTitle },
  ]

  return (
    <BasicPage
      title={reviewTitle}
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
    />
  )
}

type ServiceDeliveryReviewDTO = {
  serviceDeliveryReview?: ServiceDeliveryReview
}

const SERVICE_DELIVERY_REVIEW_QUERY = gql`
  query ServiceDeliveryReview($reviewId: ID!) {
    serviceDeliveryReview(reviewId: $reviewId) {
      id
      meetingDate
      product {
        id
        name
        slug
      }
    }
  }
`

export default ServiceDeliveryReviewPage

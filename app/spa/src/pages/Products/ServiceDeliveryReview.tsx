import { gql, useQuery } from "@apollo/client"
import BasicPage from "../../components/BasicPage"
import { ServiceDeliveryReview } from "../../modules/product/product.types"
import { useTranslation } from "react-i18next"
import { useContext } from "react"
import { MeContext } from "../../contexts/MeContext"
import { useParams } from "react-router-dom"
import ServiceDeliveryReviewCharts from "../../modules/product/components/ServiceDeliveryReviewCharts"
import ServiceDeliveryReviewDetails from "../../modules/product/components/ServiceDeliveryReviewDetails"
import { Grid } from "@mui/material"
import ServiceDeliveryReviewActions from "../../modules/product/components/ServiceDeliveryReviewActions"

const ServiceDeliveryReviewPage = () => {
  const { t } = useTranslation("serviceDeliveryReview")
  const params = useParams()

  const reviewId = params.reviewId
  const { data, loading } = useQuery<ServiceDeliveryReviewDTO>(
    SERVICE_DELIVERY_REVIEW_QUERY,
    { variables: { reviewId }, notifyOnNetworkStatusChange: true }
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
    >
      {review && (
        <Grid container spacing={2}>
          <Grid item xs={4}>
            <ServiceDeliveryReviewDetails review={review} />
          </Grid>
          <Grid item xs={8}>
            <ServiceDeliveryReviewActions review={review} />
          </Grid>
        </Grid>
      )}
      {review?.flowEvents && (
        <ServiceDeliveryReviewCharts flowEvents={review.flowEvents} />
      )}
    </BasicPage>
  )
}

type ServiceDeliveryReviewDTO = {
  serviceDeliveryReview?: ServiceDeliveryReview
}

export const SERVICE_DELIVERY_REVIEW_QUERY = gql`
  query ServiceDeliveryReview($reviewId: ID!) {
    serviceDeliveryReview(reviewId: $reviewId) {
      id
      meetingDate
      demandsCount
      discardedCount
      demandsLeadTimeP80
      bugsCount
      longestStageName
      longestStageTime
      flowEvents {
        id
        eventType
      }
      product {
        id
        name
        slug
        memberships{
          id
          teamMemberName
        }
      }
      serviceDeliveryReviewActionItems {
        id
        actionType
        createdAt
        deadline
        doneDate
        description
        membership {
          id
          teamMemberName
        }
      }
    }
  }
`

export default ServiceDeliveryReviewPage

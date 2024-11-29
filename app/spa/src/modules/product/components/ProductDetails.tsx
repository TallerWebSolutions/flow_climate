import { useTranslation } from "react-i18next"
import { useLocation, useParams } from "react-router-dom"
import { Box, Button } from "@mui/material"
import { ReactNode } from "react"

import { Product } from "../product.types"
import { Tabs } from "../../../components/Tabs"
import BasicPage from "../../../components/BasicPage"
import ProductGeneralInfo from "./ProductGeneralInfo"
import { gql } from "@apollo/client"

type ProductDetailsProps = {
  product: Product
  loading: boolean
  children?: ReactNode
}

const ProductDetails = ({
  product,
  loading,
  children,
}: ProductDetailsProps) => {
  const { pathname } = useLocation()
  const { t } = useTranslation(["products"])
  const params = useParams()

  const productSlug = params.productSlug || ""
  const productName = product?.name || ""
  const company = product?.company
  const companyName = company?.name || ""
  const companySlug = company?.slug
  const breadcrumbsLinks = [
    { name: companyName, url: `/companies/${companySlug}` },
    {
      name: t("products.title"),
      url: `/companies/${companySlug}/products`,
    },
    {
      name: productName,
      url: `/companies/${companySlug}/products/${productSlug}`,
    },
  ]

  const productTabs = [
    {
      label: t("products.product"),
      to: `/companies/${companySlug}/products/${productSlug}`,
    },
    {
      label: t("products.riskReview"),
      to: `/companies/${companySlug}/products/${productSlug}/risk_reviews_tab`,
    },
    {
      label: t("products.serviceDeliveryReview"),
      to: `/companies/${companySlug}/products/${productSlug}/service_delivery_reviews_tab`,
    },
  ]

  return (
    <BasicPage
      title={productName}
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
    >
      {product && (
        <>
          <Button
            href={`/companies/${companySlug}/jira/products/${productSlug}/jira_product_configs`}
          >
            {t("product.show.jiraProductConfigs")}
          </Button>
          <ProductGeneralInfo product={product} />
        </>
      )}
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <Tabs tabs={productTabs} currentPath={pathname} />
      </Box>
      {children}
    </BasicPage>
  )
}

ProductDetails.fragments = gql`
  fragment productDetails on Product {
    name
    slug
    usersCount
    createdDemandsCount
    deliveredDemandsCount
    remainingBacklogCount
    upstreamDemandsCount
    downstreamDemandsCount
    discardedDemandsCount
    unscoredDemandsCount
    demandsBlocksCount
    portfolioUnitsCount
    averageSpeed
    averageQueueTime
    averageTouchTime
    leadtimeP95
    leadtimeP80
    leadtimeP65
    company {
      id
      slug
      name
    }
    latestDeliveries {
      id
      externalId
      endDate
      leadtime
      demandBlocksCount
      product {
        id
        slug
        name
      }
      project {
        id
        name
      }
    }
  }
`

export default ProductDetails

import { Product } from "../product.types"
import { useTranslation } from "react-i18next"
import { useLocation, useParams } from "react-router-dom"
import { Backdrop, Box, Button, CircularProgress } from "@mui/material"
import { Tabs } from "../../../components/Tabs"
import BasicPage from "../../../components/BasicPage"
import ProductGeneralInfo from "./ProductGeneralInfo"
import React, { ReactNode } from "react"

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

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  if (!product && !loading) return <strong>{t("products.notFound")}</strong>

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
            href={`/companies/${company.slug}/jira/products/${product.slug}/jira_product_configs`}
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

export default ProductDetails

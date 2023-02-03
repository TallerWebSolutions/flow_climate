import { Product } from "../product.types"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { Backdrop, Button, CircularProgress, Link } from "@mui/material"
import BasicPage from "../../../components/BasicPage"
import ProductGeneralInfo from "./ProductGeneralInfo"
import ProductCharts from "./ProductCharts"
import React from "react"

type ProductDetailsProps = {
  product: Product
  loading: boolean
}

const ProductDetails = ({ product, loading }: ProductDetailsProps) => {
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
          <ProductCharts product={product} />
        </>
      )}
    </BasicPage>
  )
}

export default ProductDetails

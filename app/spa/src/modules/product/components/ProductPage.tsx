import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import useProductQuery from "../../../hooks/useProductQuery"
import BasicPage from "../../../components/BasicPage"
import { ReactElement } from "react"

type ProductPageProps = {
  pageName: string
  loading?: boolean
  children: ReactElement | ReactElement[]
}

export const ProductPage = ({
  pageName,
  loading,
  children,
}: ProductPageProps) => {
  const { t } = useTranslation(["products"])
  const params = useParams()
  const productSlug = params.productSlug || ""
  const { productInfo, loading: queryLoading } = useProductQuery(productSlug)

  if (!productInfo && !queryLoading)
    return <strong>{t("products.notFound")}</strong>

  const productName = productInfo?.name || ""
  const company = productInfo?.company
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
      loading={loading || queryLoading}
    >
      <>
        {productName}
        {children}
      </>
    </BasicPage>
  )
}

import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import useProductQuery from "../../hooks/useProductQuery"
import BasicPage from "../../components/BasicPage"
import { ProductGeneralInfo } from "../../modules/product/components/ProductGeneralInfo"

export const ProductPage = () => {
  const { t } = useTranslation(["products"])
  const params = useParams()
  const productSlug = params.productSlug || ""
  const { product, loading: queryLoading } = useProductQuery(productSlug)

  if (!product && !queryLoading)
    return <strong>{t("products.notFound")}</strong>

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
    <BasicPage title={productName} breadcrumbsLinks={breadcrumbsLinks}>
      <>{product && <ProductGeneralInfo product={product} />}</>
    </BasicPage>
  )
}

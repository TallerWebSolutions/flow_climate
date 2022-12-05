import { useTranslation } from "react-i18next"
import { ProductPage } from "../../modules/product/components/ProductPage"

const Product = () => {
  const { t } = useTranslation(["products"])

  return <ProductPage pageName={t("products.title")}></ProductPage>
}

export default Product

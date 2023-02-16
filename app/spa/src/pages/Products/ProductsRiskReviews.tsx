import { useParams } from "react-router-dom"
import useProductQuery from "../../hooks/useProductQuery"
import ProductDetails from "../../modules/product/components/ProductDetails"

const ProductsRiskReviews = () => {
  const params = useParams()
  const productSlug = params.productSlug || ""
  const { product, loading: queryLoading } = useProductQuery(productSlug)
  return (
    <>
      {product && (
        <ProductDetails product={product} loading={queryLoading}>
          {product?.riskReviews?.length > 0 ? (
            <h2>Risk reviews</h2>
          ) : (
            <h2>Não existem dados de revisão de risco a serem exibidos.</h2>
          )}
        </ProductDetails>
      )}
    </>
  )
}

export default ProductsRiskReviews

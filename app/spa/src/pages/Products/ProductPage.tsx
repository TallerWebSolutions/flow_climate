import { useParams } from "react-router-dom"
import useProductQuery from "../../hooks/useProductQuery"
import ProductDetails from "../../modules/product/components/ProductDetails"

const ProductPage = () => {
  const params = useParams()
  const productSlug = params.productSlug || ""
  const { product, loading: queryLoading } = useProductQuery(productSlug)

  return (
    <>
      {product && <ProductDetails product={product} loading={queryLoading} />}
    </>
  )
}

export default ProductPage

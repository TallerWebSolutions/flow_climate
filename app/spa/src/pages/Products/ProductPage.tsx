import { useParams } from "react-router-dom"
import { gql, useQuery } from "@apollo/client"

import ProductDetails from "../../modules/product/components/ProductDetails"
import ProductCharts from "../../modules/product/components/ProductCharts"
import { Product } from "../../modules/product/product.types"

const ProductPage = () => {
  const params = useParams()
  const productSlug = params.productSlug || ""
  const { data, loading } = useQuery<ProductPageDTO>(PRODUCT_PAGE_QUERY, {
    variables: { productSlug },
    notifyOnNetworkStatusChange: true,
  })

  const product = data?.product

  return (
    <>
      {product && (
        <ProductDetails product={product} loading={loading}>
          <ProductCharts product={product} />
        </ProductDetails>
      )}
    </>
  )
}

type ProductPageDTO = {
  product?: Product
}

const PRODUCT_PAGE_QUERY = gql`
  query ProductPage($productSlug: String!) {
    product(slug: $productSlug) {
      id
      leadtimeEvolutionData {
        xAxis
        yAxisInMonth
        yAxisAccumulated
      }
      ...productDetails
    }
  }

  ${ProductDetails.fragments}
`

export default ProductPage

import ProductDetails from "./ProductDetails"
import { useParams } from "react-router-dom"
import { gql, useQuery } from "@apollo/client"
import { Product } from "../product.types"

const ProductBVPTab = () => {
  const params = useParams()
  const productSlug = params.productSlug || ""
  const { data, loading } = useQuery<ProductBVPTabDTO>(PRODUCT_BVP_QUERY, {
    variables: { productSlug },
    notifyOnNetworkStatusChange: true,
  })

  const product = data?.product

  return (
    <>
      {product && (
        <ProductDetails product={product} loading={loading}>
          to be done
        </ProductDetails>
      )}
    </>
  )
}

const PRODUCT_BVP_QUERY = gql`
  query ProductBVP($productSlug: String!) {
    product(slug: $productSlug) {
      id
      ...productDetails
    }
  }

  ${ProductDetails.fragments}
`

type ProductBVPTabDTO = {
  product?: Product
}

export default ProductBVPTab

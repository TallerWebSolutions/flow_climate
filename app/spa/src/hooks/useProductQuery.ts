import { gql, useQuery } from "@apollo/client"
import { ProductInfo } from "../modules/product/product.types"

const PRODUCT_QUERY = gql`
  query ProductInfo($slug: String!) {
    product(slug: $slug) {
      id
      name
      slug
      company {
        id
        name
        slug
      }
    }
  }
`

type ProductInfoDTO = ProductInfo | undefined

const useProductQuery = (slug: string) => {
  const { data, loading, error } = useQuery<ProductInfoDTO>(PRODUCT_QUERY, {
    variables: { slug },
  })

  // eslint-disable-next-line
  console.log(error)

  return { productInfo: data?.product, loading, error }
}

export default useProductQuery

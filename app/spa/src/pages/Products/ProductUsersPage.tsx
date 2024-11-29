import { Box, Typography } from "@mui/material"
import { useParams } from "react-router-dom"
import BasicPage from "../../components/BasicPage"
import { gql, useQuery } from "@apollo/client"
import { Product } from "../../modules/product/product.types"
import { useTranslation } from "react-i18next"
import ProductUsersList, { PRODUCT_USER_FRAGMENT } from "./ProductUsersList"

const ProductUsersPage = () => {
  const params = useParams()
  const { t } = useTranslation(["products"])

  const productSlug = params.productSlug || ""

  const { data, loading } = useQuery<PRODUCT_USERS_LIST_PAGE_DTO>(
    PRODUCT_USERS_LIST_PAGE_QUERY,
    {
      variables: { productSlug },
    }
  )

  const product = data?.product
  const companyName = product?.company?.name || ""
  const companySlug = product?.company?.slug || ""
  const productName = product?.name || ""

  const breadcrumbsLinks = [
    {
      name: companyName,
      url: `/companies/${companySlug}`,
    },
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
      title={"Permissões no produto"}
      loading={loading}
      breadcrumbsLinks={breadcrumbsLinks}
    >
      <Typography component={"h5"} variant={"h5"} sx={{ marginBottom: 4 }}>
        {product?.name}
      </Typography>

      <Box sx={{ display: "flex", gap: 5 }}>
        <Box sx={{ width: "50%" }}>
          {product?.usersOutside && (
            <ProductUsersList
              users={product.usersOutside}
              productId={product.id}
              outsiders
            />
          )}
        </Box>
        <Box sx={{ width: "50%" }}>
          {product?.users && (
            <ProductUsersList users={product.users} productId={product.id} />
          )}
        </Box>
      </Box>
    </BasicPage>
  )
}

type PRODUCT_USERS_LIST_PAGE_DTO = {
  product?: Product
}

const PRODUCT_USERS_LIST_PAGE_QUERY = gql`
  query ProductUsersListPageQuery($productSlug: String!) {
    product(slug: $productSlug) {
      ...productUserFragment
    }
  }
  ${PRODUCT_USER_FRAGMENT}
`

export default ProductUsersPage

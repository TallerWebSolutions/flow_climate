import { User } from "../../modules/user/user.types"
import { Box, Button, Typography } from "@mui/material"
import { AddCircleOutline } from "@mui/icons-material"
import DeleteIcon from "@mui/icons-material/Delete"
import { gql, useMutation } from "@apollo/client"

type ProductUsersOutsideListProps = {
  productId: string
  users: User[]
  outsiders?: boolean
}

const ProductUsersList = ({
  users,
  productId,
  outsiders = false,
}: ProductUsersOutsideListProps) => {
  const [toggleUserMutation] = useMutation(TOGGLE_PRODUCT_USER_MUTATION)

  return (
    <>
      {users.map((user, index) => (
        <Box
          sx={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            paddingY: 1,
            paddingX: 4,
            backgroundColor: index % 2 === 0 ? "white" : "#d9ceda",
            borderRadius: 2,
          }}
        >
          <Typography key={index}>
            {user.fullName} ({user.email})
          </Typography>
          <Button
            onClick={() =>
              toggleUserMutation({
                variables: { productId: productId, userId: user.id },
              })
            }
          >
            {outsiders ? <AddCircleOutline /> : <DeleteIcon />}
          </Button>
        </Box>
      ))}
    </>
  )
}

export const PRODUCT_USER_FRAGMENT = gql`
  fragment productUserFragment on Product {
    id
    slug
    name
    company {
      id
      slug
      name
    }
    users {
      id
      fullName
      email
    }
    usersOutside {
      id
      fullName
      email
    }
  }
`

const TOGGLE_PRODUCT_USER_MUTATION = gql`
  mutation ToggleProductUser($productId: ID!, $userId: ID!) {
    toggleProductUser(productId: $productId, userId: $userId) {
      product {
        ...productUserFragment
      }
      statusMessage
    }
  }
  ${PRODUCT_USER_FRAGMENT}
`

export default ProductUsersList

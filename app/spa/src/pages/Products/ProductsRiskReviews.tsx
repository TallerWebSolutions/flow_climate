import { Link, useParams } from "react-router-dom"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography,
  Button,
  Link as MaterialLink,
  ButtonGroup,
} from "@mui/material"
import DeleteIcon from "@mui/icons-material/Delete"
import { useTranslation } from "react-i18next"
import { gql, useMutation, useQuery } from "@apollo/client"
import { useContext } from "react"

import ProductDetails from "../../modules/product/components/ProductDetails"
import { formatDate } from "../../lib/date"
import { Product } from "../../modules/product/product.types"
import { MessagesContext } from "../../contexts/MessageContext"

const ProductsRiskReviews = () => {
  const params = useParams()
  const { t } = useTranslation("riskReview")
  const productSlug = params.productSlug || ""
  const companySlug = params.companySlug || ""
  const { data, loading } = useQuery<ProductRiskReviewsPageDTO>(
    PRODUCT_RISK_REVIEWS_PAGE_QUERY,
    {
      variables: { productSlug },
    }
  )
  const { pushMessage } = useContext(MessagesContext)
  const [deleteRiskReview] = useMutation<DeleteRiskReviewDTO>(
    DELETE_RISK_REVIEW_MUTATION,
    {
      update: (_, { data }) => {
        const mutationResult =
          data?.deleteProductRiskReview?.statusMessage === "SUCCESS"

        pushMessage({
          text: mutationResult
            ? t("riskReviews.deletedRiskReviewSuccess")
            : t("riskReviews.deletedRiskReviewFail"),
          severity: mutationResult ? "success" : "error",
        })
      },
      refetchQueries: ["ProductRiskReviewsPage"],
    }
  )

  const product = data?.product

  return !!product ? (
    <ProductDetails product={product} loading={loading}>
      <Button
        component={Link}
        to={`/companies/${companySlug}/products/${productSlug}/risk_reviews/new`}
        variant="contained"
        sx={{ marginY: 2 }}
      >
        {t("new.title")}
      </Button>
      <Table>
        <TableHead>
          <TableRow
            sx={{
              borderBottom: "1px solid",
              borderBottomColor: "grwy.200",
            }}
          >
            <TableCell>{t("riskReviews.riskReviewID")}</TableCell>
            <TableCell>{t("riskReviews.leadTimeOutlierLimit")}</TableCell>
            <TableCell>{t("riskReviews.meetingDate")}</TableCell>
            <TableCell>{t("riskReviews.createdAt")}</TableCell>
            <TableCell>{t("riskReviews.actions")}</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {!!product?.riskReviews?.length ? (
            product.riskReviews.map((riskReview) => (
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "grwy.200",
                }}
              >
                <TableCell>
                  <MaterialLink
                    href={`/companies/${companySlug}/products/${productSlug}/risk_reviews/${riskReview.id}`}
                  >
                    {riskReview.id}
                  </MaterialLink>
                </TableCell>
                <TableCell>{riskReview.leadTimeOutlierLimit}</TableCell>
                <TableCell>
                  {riskReview.meetingDate &&
                    formatDate({
                      date: riskReview.meetingDate,
                    })}
                </TableCell>
                <TableCell>
                  {riskReview.createdAt &&
                    formatDate({
                      date: riskReview.createdAt,
                      format: "dd/MM/yyyy' 'HH:mm:ss",
                    })}
                </TableCell>
                <TableCell>
                  <ButtonGroup>
                    <Button
                      variant="text"
                      onClick={() =>
                        deleteRiskReview({
                          variables: { riskReviewId: riskReview.id },
                        })
                      }
                    >
                      <DeleteIcon />
                    </Button>
                  </ButtonGroup>
                </TableCell>
              </TableRow>
            ))
          ) : (
            <TableCell colSpan={6} align="center">
              <Typography variant="h6" sx={{ fontWeight: 500 }}>
                Não existem dados de revisão de risco a serem exibidos.
              </Typography>
            </TableCell>
          )}
        </TableBody>
      </Table>
    </ProductDetails>
  ) : null
}

type ProductRiskReviewsPageDTO = {
  product?: Product
}

const PRODUCT_RISK_REVIEWS_PAGE_QUERY = gql`
  query ProductRiskReviewsPage($productSlug: String!) {
    product(slug: $productSlug) {
      id
      riskReviews {
        id
        leadTimeOutlierLimit
        meetingDate
        monthlyAvgBlockedTime
        weeklyAvgBlockedTime
        createdAt
      }
      ...productDetails
    }
  }

  ${ProductDetails.fragments}
`

type DeleteRiskReviewDTO = {
  deleteProductRiskReview?: {
    statusMessage?: string
  }
}

const DELETE_RISK_REVIEW_MUTATION = gql`
  mutation DeleteRiskReview($riskReviewId: ID!) {
    deleteProductRiskReview(riskReviewId: $riskReviewId) {
      statusMessage
    }
  }
`

export default ProductsRiskReviews

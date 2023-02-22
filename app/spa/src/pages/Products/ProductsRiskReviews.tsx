import { Link, useParams } from "react-router-dom"
import useProductQuery from "../../hooks/useProductQuery"
import ProductDetails from "../../modules/product/components/ProductDetails"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography,
  Button,
  Link as MaterialLink,
} from "@mui/material"
import { useTranslation } from "react-i18next"
import { formatDate } from "../../lib/date"

const ProductsRiskReviews = () => {
  const params = useParams()
  const productSlug = params.productSlug || ""
  const companySlug = params.companySlug || ""
  const { product, loading } = useProductQuery(productSlug)

  const { t } = useTranslation("riskReviews")

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
              borderBottomColor: "grey.200",
            }}
          >
            <TableCell>{t("riskReviews.riskReviewID")}</TableCell>
            <TableCell>{t("riskReviews.leadTimeOutlierLimit")}</TableCell>
            <TableCell>{t("riskReviews.meetingDate")}</TableCell>
            <TableCell>{t("riskReviews.createdAt")}</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {product?.riskReviews?.length > 0 ? (
            product.riskReviews.map((riskReview) => (
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "grey.200",
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
              </TableRow>
            ))
          ) : (
            <TableCell colSpan={5} align="center">
              <Typography
                variant="h6"
                color="#1E1E1E"
                sx={{ fontSize: 17, fontWeight: 500 }}
              >
                Não existem dados de revisão de risco a serem exibidos.
              </Typography>
            </TableCell>
          )}
        </TableBody>
      </Table>
    </ProductDetails>
  ) : null
}

export default ProductsRiskReviews

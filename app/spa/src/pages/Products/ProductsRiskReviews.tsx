import { useParams } from "react-router-dom"
import useProductQuery from "../../hooks/useProductQuery"
import ProductDetails from "../../modules/product/components/ProductDetails"
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Typography,
  Box,
  Link,
} from "@mui/material"
import { useTranslation } from "react-i18next"
import { formatDate, secondsToHours } from "../../lib/date"

const ProductsRiskReviews = () => {
  const params = useParams()
  const productSlug = params.productSlug || ""
  const companySlug = params.companySlug || ""
  const { product, loading: queryLoading } = useProductQuery(productSlug)

  const { t: tRiskReview } = useTranslation(["riskReviews"])

  function convertSecondsToHours(listOfNumbers: number[]) {
    const convertedNumbers = listOfNumbers.map((item) => secondsToHours(item))
    return convertedNumbers.slice(0, 3).join(", ")
  }

  return (
    <>
      {product && (
        <ProductDetails product={product} loading={queryLoading}>
          <Box display="flex" justifyContent="center">
            <TableContainer
              component={Paper}
              sx={{ background: "white", maxWidth: 1000 }}
            >
              <Table>
                <TableHead>
                  <TableRow
                    sx={{
                      borderBottom: "1px solid",
                      borderBottomColor: "grey.200",
                    }}
                  >
                    <TableCell>
                      {tRiskReview("riskReviews.riskReviewID")}
                    </TableCell>
                    <TableCell>
                      {tRiskReview("riskReviews.leadTimeOutlierLimit")}
                    </TableCell>
                    <TableCell>
                      {tRiskReview("riskReviews.meetingDate")}
                    </TableCell>
                    <TableCell>
                      {tRiskReview("riskReviews.monthlyAvgBlockedTime")}
                    </TableCell>
                    <TableCell>
                      {tRiskReview("riskReviews.weeklyAvgBlockedTime")}
                    </TableCell>
                    <TableCell>
                      {tRiskReview("riskReviews.createdAt")}
                    </TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {product?.riskReviews?.length > 0 ? (
                    <>
                      {product.riskReviews.map((riskReview) => (
                        <TableRow
                          sx={{
                            borderBottom: "1px solid",
                            borderBottomColor: "grey.200",
                          }}
                        >
                          <TableCell>
                            <Link
                              href={`/companies/${companySlug}/products/${productSlug}/risk_reviews/${riskReview.id}`}
                            >
                              {riskReview.id}
                            </Link>
                          </TableCell>
                          <TableCell>
                            {riskReview.leadTimeOutlierLimit}
                          </TableCell>
                          <TableCell>
                            {formatDate({
                              date: riskReview.meetingDate,
                            })}
                          </TableCell>
                          <TableCell>
                            {riskReview.monthlyAvgBlockedTime != null && (
                              <>
                                {convertSecondsToHours(
                                  riskReview.monthlyAvgBlockedTime
                                )}
                              </>
                            )}
                          </TableCell>
                          <TableCell>
                            {riskReview.weeklyAvgBlockedTime != null && (
                              <>
                                {convertSecondsToHours(
                                  riskReview.weeklyAvgBlockedTime
                                )}
                              </>
                            )}
                          </TableCell>
                          <TableCell>
                            {formatDate({
                              date: riskReview.createdAt,
                              format: "dd/MM/yyyy' 'HH:mm:ss",
                            })}
                          </TableCell>
                        </TableRow>
                      ))}
                    </>
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
            </TableContainer>
          </Box>
        </ProductDetails>
      )}
    </>
  )
}

export default ProductsRiskReviews

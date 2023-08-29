import { useNavigate, useParams, useLocation } from "react-router-dom"
import BasicPage, { BasicPageProps } from "../../components/BasicPage"
import useProductQuery from "../../hooks/useProductQuery"
import { useTranslation } from "react-i18next"
import { secondsToDays } from "../../lib/date"

import {
  Box,
  Button,
  Grid,
  Paper,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
  Select,
  Table,
  TableContainer,
  TableBody,
  TableCell,
  TableCellProps,
  TableHead,
  TableRow,
  TableRowProps,
  Typography,
  Link,
  ButtonGroup,
} from "@mui/material"
import DeleteIcon from "@mui/icons-material/Delete"
import { formatDate } from "../../lib/date"
import { FieldValues, useForm } from "react-hook-form"
import { gql, useMutation, useQuery } from "@apollo/client"
import { Product } from "../../modules/product/product.types"
import { PRODUCT_QUERY } from "../../hooks/useProductQuery"
import ProductDetails from "../../modules/product/components/ProductDetails"
import ProductGeneralInfo from "../../../src/modules/product/components/ProductGeneralInfo"
import { useContext, useState } from "react"
import { MessagesContext } from "../../contexts/MessageContext"
import { Tabs } from "../../components/Tabs"
import ProductGeneralInfoTable from "../../../src/modules/product/components/ProductGeneralInfoTable"
import { ReadMoreButton } from "../../../src/components/ReadMoreButton"

const Row = (props: TableRowProps) => (
  <TableRow
    sx={{
      borderBottom: "1px solid",
      borderBottomColor: "#ccc",
    }}
    {...props}
  />
)

const Cell = (props: TableCellProps) => (
  <TableCell
    sx={{
      padding: 2,
    }}
    {...props}
  />
)



  const ShowProductsRiskReview = () => {

    const params = useParams()

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
    const riskReview = data?.product?.riskReviews
    const { pathname } = useLocation()

    
    const { t } = useTranslation("riskReview")
    

    const { t: tDemands } = useTranslation(["demand"])
    const [readMore, setReadMore] = useState(true)
    const company = product?.company

    const productId = product?.id || ""

    const productTabs = [
      {
        label: t("products.product"),
        to: `/companies/${companySlug}/products/${productSlug}`,
      },
      {
        label: t("products.riskReview"),
        to: `/companies/${companySlug}/products/${productSlug}/risk_reviews_tab`,
      },
      {
        label: t("products.serviceDeliveryReview"),
        to: `/companies/${companySlug}/products/${productSlug}/service_delivery_reviews_tab`,
      },
    ]

    

      return !!product ? (
        <BasicPage
        title={"alou"}
        loading={false}
        breadcrumbsLinks={[]}
      >
        <h1>{"Vamos lá chchu!"}</h1>

        <p> {"product.riskReviews"} </p>

        {product && (
        <>
          <Button
            href={`/companies/${companySlug}/jira/products/${product.slug}/jira_product_configs`}
          >
            {t("product.show.jiraProductConfigs")}
          </Button>

          <Grid container spacing={2}>
            <Grid item xs={4} sx={{ padding: "16px" }}>
              <TableContainer component={Paper} sx={{ background: "white", marginY: 4 }}>
                <Typography
                  color="primary"
                  variant="h6"
                  component="h6"
                  sx={{ padding: "16px " }}
                >
                  {tDemands("list.demandsTable.generalInfo")}
                </Typography>
                <Box
                  sx={{
                    position: "relative",
                    height: readMore ? "586px" : "auto",
                    overflow: readMore ? "hidden" : "",
                  }}
                >
                  <Table>
                    <Row>
                      <Cell>
                        <Typography component="span">
                          {tDemands("list.demandsTable.createdDemands")}
                        </Typography>
                      </Cell>
                      <Cell align="right">
                        <Link
                          href={
                            `/companies/${companySlug}/demands/demands_list_by_ids?` +
                            `demand_state=created&flow_object_id=${productId}&object_type=Product`
                          }
                          sx={{ color: "info.dark", textDecoration: "none" }}
                        >

                          {product.createdDemandsCount}
                        </Link>
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>
                        <Typography component="span">
                          {tDemands("list.demandsTable.deliveredDemands")}
                        </Typography>
                      </Cell>
                      <Cell align="right">
                        <Link
                          href={
                            `/companies/${companySlug}/demands/demands_list_by_ids?` +
                            `demand_state=delivered&flow_object_id=${productId}&object_type=Product`
                          }
                          sx={{ color: "info.dark", textDecoration: "none" }}
                        >
                          {product.deliveredDemandsCount}
                        </Link>
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>
                        <Box component="span">
                          {tDemands("list.demandsTable.backlog")}
                        </Box>
                      </Cell>
                      <Cell align="right">
                        <Link
                          href={
                            `/companies/${companySlug}/demands/demands_list_by_ids?` +
                            `demand_state=backlog&flow_object_id=${productId}&object_type=Product`
                          }
                          sx={{ color: "info.dark", textDecoration: "none" }}
                        >
                          {product.remainingBacklogCount}
                        </Link>
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>
                        <Box component="span">
                          {tDemands("list.demandsTable.upstreamDemands")}
                        </Box>
                      </Cell>
                      <Cell align="right">
                        <Link
                          href={
                            `/companies/${companySlug}/demands/demands_list_by_ids?` +
                            `demand_state=upstream&flow_object_id=${productId}&object_type=Product`
                          }
                          sx={{ color: "info.dark", textDecoration: "none" }}
                        >
                          {product.upstreamDemandsCount}
                        </Link>
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>
                        <Box component="span">
                          {tDemands("list.demandsTable.downstreamDemands")}
                        </Box>
                      </Cell>
                      <Cell align="right">
                        <Link
                          href={
                            `/companies/${companySlug}/demands/demands_list_by_ids?` +
                            `demand_state=downstream&flow_object_id=${productId}&object_type=Product`
                          }
                          sx={{ color: "info.dark", textDecoration: "none" }}
                        >
                          {product.downstreamDemandsCount}
                        </Link>
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>{tDemands("list.demandsTable.discardedDemands")}</Cell>
                      <Cell align="right">
                        <Link
                          href={
                            `/companies/${companySlug}/demands/demands_list_by_ids?` +
                            `demand_state=discarded&flow_object_id=${productId}&object_type=Product`
                          }
                          sx={{ color: "info.dark", textDecoration: "none" }}
                        >
                          {product.discardedDemandsCount}
                        </Link>
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>{tDemands("list.demandsTable.unscoredDemands")}</Cell>
                      <Cell align="right">
                        <Link
                          href={
                            `/companies/${companySlug}/demands/demands_list_by_ids?` +
                            `demand_state=unscored&flow_object_id=${productId}&object_type=Product`
                          }
                          sx={{ color: "info.dark", textDecoration: "none" }}
                        >
                          {product.unscoredDemandsCount}
                        </Link>
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>{tDemands("list.demandsTable.demandBlocks")}</Cell>
                      <Cell align="right">
                        <Typography sx={{ color: "info.dark", textDecoration: "none" }}>
                          {product.demandsBlocksCount}
                        </Typography>
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>{tDemands("list.demandsTable.portfolioUnits")}</Cell>
                      <Cell align="right">
                        <Link
                          href={`/companies/${companySlug}/products/${productId}/portfolio_units`}
                          sx={{ color: "info.dark", textDecoration: "none" }}
                        >
                          {product.portfolioUnitsCount}
                        </Link>
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>
                        {tDemands("list.demandsTable.averageSpeed", {
                          numberOfDemandsPerDay: product.averageSpeed?.toFixed(2),
                        })}
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>
                        {tDemands("list.demandsTable.averageQueueTime", {
                          time: secondsToDays(product.averageQueueTime).toFixed(2),
                        })}
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>
                        {tDemands("list.demandsTable.averageWorkTime", {
                          time: secondsToDays(product.averageTouchTime).toFixed(2),
                        })}
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>
                        {tDemands("list.demandsTable.leadTimeP95", {
                          days: secondsToDays(product.leadtimeP95).toFixed(2),
                        })}
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>
                        {tDemands("list.demandsTable.leadTimeP80", {
                          days: secondsToDays(product.leadtimeP80).toFixed(2),
                        })}
                      </Cell>
                    </Row>
                    <Row>
                      <Cell>
                        {tDemands("list.demandsTable.leadTimeP65", {
                          days: secondsToDays(product.leadtimeP65).toFixed(2),
                        })}
                      </Cell>
                    </Row>
                  </Table>
                  {readMore && (
                    <ReadMoreButton handleDisplayPostContent={() => setReadMore(false)} />
                  )}
                </Box>
              </TableContainer>
            </Grid>

            
              <Grid item xs={8} sx={{ padding: "16px" }}>
                
              </Grid>
            
          </Grid>
        </>
      )}
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <Tabs tabs={productTabs} currentPath={pathname} />
      </Box>

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
            <TableCell>{t("riskReviews.actions")}</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {!!product?.riskReviews?.length ? (
            product.riskReviews.map((riskReview) => (
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

        

        </BasicPage>
        
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
            demandsCount
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


export default ShowProductsRiskReview

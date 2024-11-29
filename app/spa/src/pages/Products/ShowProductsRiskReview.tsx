import { useParams, useLocation } from "react-router-dom"
import BasicPage from "../../components/BasicPage"
import { useTranslation } from "react-i18next"
import { FormElement } from "../../components/ui/Form"
import SearchIcon from "@mui/icons-material/Search"
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
import { useForm } from "react-hook-form"
import { gql, useMutation, useQuery } from "@apollo/client"
import { RiskReview } from "../../modules/product/product.types"
import { useContext } from "react"
import { MessagesContext } from "../../contexts/MessageContext"
import { Tabs } from "../../components/Tabs"

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
  const { register } = useForm()

  const productSlug = params.productSlug || ""
  const companySlug = params.companySlug || ""

  const { data } = useQuery<RiskReviewPageDTO>(RISK_REVIEW_PAGE_QUERY, {
    variables: { id: params.riskReviewId },
  })

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

  const riskReview = data?.riskReview
  const { pathname } = useLocation()

  const { t } = useTranslation("riskReview")

  const { t: tDemands } = useTranslation(["demand"])
  const company = riskReview?.product?.company

  const productId = riskReview?.product?.id || ""

  const productTabs = [
    {
      label: t("riskReviews.demands"),
      to: ``,
    },
    {
      label: t("riskReviews.demandsOutlier"),
      to: ``,
    },
    {
      label: t("riskReviews.bugs"),
      to: ``,
    },
    {
      label: t("riskReviews.demandBlocks"),
      to: ``,
    },
    {
      label: t("riskReviews.flowEvents"),
      to: ``,
    },
  ]

  return (
    <BasicPage title={""} loading={false} breadcrumbsLinks={[]}>
      <>
        <Grid container spacing={3}>
          <Grid item xs={4} sx={{ padding: "16px" }}>
            <Typography color="primary" variant="h6" component="h6" sx={{}}>
              {t("riskReviews.meetingDate")}
            </Typography>
            <Typography color="primary" variant="h4" component="h4" sx={{}}>
              {(riskReview?.meetingDate
                ? riskReview.meetingDate
                : Date()
              ).toLocaleString()}
            </Typography>
            <TableContainer
              component={Paper}
              sx={{ background: "white", marginY: 4 }}
            >
              <Box
                sx={{
                  position: "relative",
                  height: "auto",
                  overflow: "hidden",
                }}
              >
                <Table>
                  <Row>
                    <Cell>
                      <Typography component="span">
                        {t("riskReviews.demandsCount")}
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
                        {riskReview?.demandsCount}
                      </Link>
                    </Cell>
                  </Row>
                  <Row>
                    <Cell>
                      <Typography component="span">
                        {t("riskReviews.leadTime")}
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
                        {riskReview?.demandsLeadTimeP80 &&
                          `${(
                            riskReview.demandsLeadTimeP80 / 86400
                          ).toPrecision(4)} dias`}
                      </Link>
                    </Cell>
                  </Row>
                  <Row>
                    <Cell>
                      <Box component="span">
                        {t("riskReviews.leadTimeOutlierLimit")}
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
                        {`${(riskReview?.leadTimeOutlierLimit
                          ? riskReview.leadTimeOutlierLimit
                          : 0
                        ).toPrecision(3)} dias`}
                      </Link>
                    </Cell>
                  </Row>
                  <Row>
                    <Cell>
                      <Box component="span">
                        {t("riskReviews.outlierDemands")}
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
                        {riskReview?.outlierDemandsCount}
                        <sup>
                          (
                          {riskReview?.outlierDemandsPercentage &&
                            riskReview.outlierDemandsPercentage.toPrecision(2)}
                          %)
                        </sup>
                      </Link>
                    </Cell>
                  </Row>
                  <Row>
                    <Cell>
                      <Box component="span">{t("riskReviews.bugsCount")}</Box>
                    </Cell>
                    <Cell align="right">
                      <Link
                        href={
                          `/companies/${companySlug}/demands/demands_list_by_ids?` +
                          `demand_state=downstream&flow_object_id=${productId}&object_type=Product`
                        }
                        sx={{ color: "info.dark", textDecoration: "none" }}
                      >
                        {riskReview?.bugsCount}
                        <sup>
                          (
                          {riskReview?.bugPercentage &&
                            riskReview.bugPercentage.toPrecision(3)}
                          %)
                        </sup>
                      </Link>
                    </Cell>
                  </Row>
                  <Row>
                    <Cell>{t("riskReviews.blocksPerDemand")}</Cell>
                    <Cell align="right">
                      <Link
                        href={
                          `/companies/${companySlug}/demands/demands_list_by_ids?` +
                          `demand_state=discarded&flow_object_id=${productId}&object_type=Product`
                        }
                        sx={{ color: "info.dark", textDecoration: "none" }}
                      >
                        {riskReview?.blocksPerDemand &&
                          riskReview.blocksPerDemand.toPrecision(2)}
                      </Link>
                    </Cell>
                  </Row>
                  <Row>
                    <Cell>{t("riskReviews.flowEventsCount")}</Cell>
                    <Cell align="right">
                      <Link
                        href={
                          `/companies/${companySlug}/demands/demands_list_by_ids?` +
                          `demand_state=unscored&flow_object_id=${productId}&object_type=Product`
                        }
                        sx={{ color: "info.dark", textDecoration: "none" }}
                      >
                        {riskReview?.flowEventsCount}
                      </Link>
                    </Cell>
                  </Row>
                  <Row>
                    <Cell>{t("riskReviews.eventsPerDemand")}</Cell>
                    <Cell align="right">
                      <Typography
                        sx={{ color: "info.dark", textDecoration: "none" }}
                      >
                        {riskReview?.eventsPerDemand &&
                          riskReview.eventsPerDemand.toPrecision(4)}
                      </Typography>
                    </Cell>
                  </Row>
                  <Row>
                    <Cell>{t("riskReviews.projectBrokenWipCount")}</Cell>
                    <Cell align="right">
                      <Link
                        href={`/companies/${companySlug}/products/${productId}/portfolio_units`}
                        sx={{ color: "info.dark", textDecoration: "none" }}
                      >
                        {riskReview?.projectBrokenWipCount}
                      </Link>
                    </Cell>
                  </Row>
                </Table>
              </Box>
            </TableContainer>
          </Grid>
          <Grid item xs={8} sx={{ padding: "16px" }}>
            <Typography color="primary" variant="h6" component="h6" sx={{}}>
              {t("riskReviews.riskReviewActions")}
            </Typography>

            <form>
              <FormGroup sx={{ display: "none" }}>
                <Grid container xs={12} rowSpacing={4} columnSpacing={1}>
                  <Grid item xs={6}>
                    <FormElement>
                      <InputLabel htmlFor="startDate">
                        {t("list.form.startDate")}
                      </InputLabel>
                      <Input
                        type="date"
                        defaultValue={0}
                        {...register("startDate")}
                        sx={{ width: 400, padding: 2 }}
                      />
                    </FormElement>
                  </Grid>
                  <Grid item xs={6}>
                    <FormElement>
                      <InputLabel htmlFor="endDate">
                        {t("list.form.endDate")}
                      </InputLabel>
                      <Input
                        type="date"
                        defaultValue={0}
                        {...register("endDate")}
                        sx={{ width: [20, 400], padding: 2 }}
                      />
                    </FormElement>
                  </Grid>
                  <FormElement>
                    <InputLabel
                      htmlFor="demandStatus"
                      sx={{ backgroundColor: "white" }}
                      shrink
                    >
                      {t("list.form.status.title")}
                    </InputLabel>
                    <Select
                      native
                      {...register("demandStatus")}
                      defaultValue={[0]}
                    >
                      <option value="">
                        {t("list.form.common.placeholder")}
                      </option>
                      <option value="ALL_DEMANDS">
                        {t("list.form.status.all")}
                      </option>
                      <option value="NOT_COMMITTED">
                        {t("list.form.status.notCommitted")}
                      </option>
                      <option value="WORK_IN_PROGRESS">
                        {t("list.form.status.wip")}
                      </option>
                      <option value="DELIVERED_DEMANDS">
                        {t("list.form.status.delivered")}
                      </option>
                      <option value="NOT_STARTED">
                        {t("list.form.status.notStarted")}
                      </option>
                      <option value="DISCARDED_DEMANDS">
                        {t("list.form.status.discarded")}
                      </option>
                      <option value="NOT_DISCARDED_DEMANDS">
                        {t("list.form.status.notDiscarded")}
                      </option>
                    </Select>
                  </FormElement>

                  <FormElement>
                    <InputLabel
                      htmlFor="team"
                      sx={{ backgroundColor: "white" }}
                      shrink
                    >
                      {t("list.form.team")}
                    </InputLabel>
                    <Select native {...register("team")} defaultValue={0}>
                      <option value="">
                        {t("list.form.common.placeholder")}
                      </option>
                    </Select>
                  </FormElement>
                  <FormElement>
                    <InputLabel
                      htmlFor="demandType"
                      sx={{ backgroundColor: "white" }}
                      shrink
                    >
                      {t("list.form.demandType")}
                    </InputLabel>
                    <Select native {...register("demandType")} defaultValue={0}>
                      <option value="">
                        {t("list.form.common.placeholder")}
                      </option>
                      {company?.workItemTypes?.map((type, index) => (
                        <option value={type.name} key={`${type.id}--${index}`}>
                          {type.name}
                        </option>
                      ))}
                    </Select>
                  </FormElement>
                  <FormElement>
                    <Button sx={{ alignSelf: "flex-start" }} type="submit">
                      <SearchIcon fontSize="large" color="primary" />
                    </Button>
                  </FormElement>

                  <FormControl sx={{ marginBottom: 4 }}>
                    <InputLabel htmlFor="name">{t("form.name")}</InputLabel>
                    <Input
                      {...register("name", { required: true })}
                      defaultValue={0}
                    />
                  </FormControl>
                </Grid>
              </FormGroup>
            </form>
          </Grid>
        </Grid>
        <Grid item xs={8} sx={{ padding: "16px" }}></Grid>
      </>

      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <Tabs tabs={productTabs} currentPath={pathname} />
      </Box>

      <Typography color="primary" variant="h6" component="h6" sx={{}}>
        {`Total: ${riskReview?.demandsCount} Demanda(s)`}
      </Typography>

      <Table>
        <TableHead>
          <TableRow
            sx={{
              borderBottom: "1px solid",
              borderBottomColor: "grwy.200",
            }}
          >
            <TableCell>
              {tDemands("list.demandsTable.portfolioUnits")}
            </TableCell>
            <TableCell>{tDemands("list.demandsTable.demandId")}</TableCell>
            <TableCell>{tDemands("list.demandsTable.demandType")}</TableCell>
            <TableCell>
              {tDemands("list.demandsTable.classOfService")}
            </TableCell>
            <TableCell>{tDemands("list.demandsTable.currentStage")}</TableCell>
            <TableCell>{tDemands("list.demandsTable.createdDate")}</TableCell>
            <TableCell>
              {tDemands("list.demandsTable.commitmentDate")}
            </TableCell>
            <TableCell>{tDemands("list.demandsTable.deliveryDate")}</TableCell>
            <TableCell>{tDemands("list.demandsTable.leadTime")}</TableCell>
            <TableCell>{tDemands("list.demandsTable.demandTitle")}</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {!!riskReview?.demands?.length ? (
            riskReview.demands.map((demands) => (
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "grwy.200",
                }}
              >
                <TableCell>
                  <Link
                    href={`/companies/${companySlug}/products/${productSlug}/risk_reviews/${demands.id}`}
                  >
                    {demands.portfolioUnitName}
                  </Link>
                </TableCell>
                <TableCell>{demands.externalId}</TableCell>
                <TableCell>{demands.demandType}</TableCell>
                <TableCell>{demands.classOfService}</TableCell>
                <TableCell>{demands.currentStageName}</TableCell>
                <TableCell>
                  {demands.createdDate &&
                    formatDate({
                      date: demands.createdDate,
                    })}
                </TableCell>
                <TableCell>
                  {demands.commitmentDate &&
                    formatDate({
                      date: demands.commitmentDate,
                    })}
                </TableCell>
                <TableCell>
                  {demands.endDate &&
                    formatDate({
                      date: demands.endDate,
                    })}
                </TableCell>
                <TableCell>{demands.leadtime}</TableCell>
                <TableCell>{demands.demandTitle}</TableCell>
                <TableCell>
                  <ButtonGroup>
                    <Button
                      variant="text"
                      onClick={() =>
                        deleteRiskReview({
                          variables: { riskReviewId: demands.id },
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
  )
}

type RiskReviewPageDTO = {
  riskReview?: RiskReview
}

const RISK_REVIEW_PAGE_QUERY = gql`
  query RiskReviewPage($id: ID!) {
    riskReview(id: $id) {
      id
      demandsCount
      demandsLeadTimeP80
      outlierDemandsCount
      outlierDemandsPercentage
      leadTimeOutlierLimit
      product {
        id
        company {
          id
          slug
          name
        }
      }
      bugsCount
      bugPercentage
      blocksPerDemand
      flowEventsCount
      eventsPerDemand
      projectBrokenWipCount
      meetingDate
      monthlyAvgBlockedTime
      weeklyAvgBlockedTime
      createdAt
      demands {
        id
        demandTitle
        demandType
        endDate
        classOfService
        currentStageName
        commitmentDate
        createdDate
        externalId
        leadtime
        costToProject
        effortUpstream
        effortDownstream
        portfolioUnitName
        projectName
        productName
        demandBlocksCount
        discardedAt
      }
    }
  }
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

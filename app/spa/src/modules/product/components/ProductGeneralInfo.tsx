import {
  Box,
  Grid,
  Link,
  Paper,
  Table,
  TableCell,
  TableCellProps,
  TableContainer,
  TableRow,
  TableRowProps,
  Typography,
} from "@mui/material"

import { useTranslation } from "react-i18next"
import { useState } from "react"
import { Product } from "../product.types"
import LatestDeliveriesTable from "../../demand/components/LatestDeliveriesTable"
import { secondsToDays } from "../../../lib/date"
import { ReadMoreButton } from "../../../components/ReadMoreButton"

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

type ProductGeneralInfoProps = {
  product: Product
}

export const ProductGeneralInfo = ({ product }: ProductGeneralInfoProps) => {
  const { t } = useTranslation(["product"])
  const [readMore, setReadMore] = useState(true)
  const lastestDeliveries = product.latestDeliveries
  const baseLink = `/companies/${product?.company?.slug}`
  const company = product?.company
  const productId = product?.id || ""

  const companySlug = company?.slug || ""

  return (
    <Grid container spacing={2}>
      <Grid item xs={4} sx={{ padding: "16px" }}>
        <TableContainer
          component={Paper}
          sx={{ background: "white", marginY: 4 }}
        >
          <Typography
            color="primary"
            variant="h6"
            component="h6"
            sx={{ padding: "16px " }}
          >
            {t("demands.deliverablesTable.generalInfo")}
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
                    {t("demands.deliverablesTable.createdDemands")}
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
                    {t("demands.deliverablesTable.deliveredDemands")}
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
                    {t("demands.deliverablesTable.backlog")}
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
                    {t("demands.deliverablesTable.upstreamDemands")}
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
                    {t("demands.deliverablesTable.downstreamDemands")}
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
                <Cell>{t("demands.deliverablesTable.discartedDemands")}</Cell>
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
                <Cell>{t("demands.deliverablesTable.unscoredDemands")}</Cell>
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
                <Cell>{t("demands.deliverablesTable.demandBlocks")}</Cell>
                <Cell align="right">
                  <Typography
                    sx={{ color: "info.dark", textDecoration: "none" }}
                  >
                    {product.demandsBlocksCount}
                  </Typography>
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("demands.deliverablesTable.averageSpeed", {
                    numberOfDemandsPerDay: product.averageSpeed.toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("demands.deliverablesTable.averageQueueTime", {
                    time: secondsToDays(product.averageQueueTime).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("demands.deliverablesTable.averageWorkTime", {
                    time: secondsToDays(product.averageTouchTime).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("demands.deliverablesTable.leadTimeP95", {
                    days: secondsToDays(product.leadTimeP95).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("demands.deliverablesTable.leadTimeP80", {
                    days: secondsToDays(product.leadTimeP80).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("demands.deliverablesTable.lead_time_p65", {
                    days: secondsToDays(product.leadTimeP65).toFixed(2),
                  })}
                </Cell>
              </Row>
            </Table>
            {readMore && (
              <ReadMoreButton
                handleDisplayPostContent={() => setReadMore(false)}
              />
            )}
          </Box>
        </TableContainer>
      </Grid>

      <Grid item xs={8} sx={{ padding: "16px" }}>
        <LatestDeliveriesTable
          demands={lastestDeliveries}
          baseLink={baseLink}
        />
      </Grid>
    </Grid>
  )
}

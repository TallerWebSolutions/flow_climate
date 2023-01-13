import {
  Box,
  Link,
  Paper,
  Table,
  TableContainer,
  Typography,
  TableRow,
  TableCell,
  TableCellProps,
  TableRowProps,
} from "@mui/material"
import { secondsToDays } from "../../../lib/date"
import { ReadMoreButton } from "../../../components/ReadMoreButton"
import { useTranslation } from "react-i18next"
import { useState } from "react"
import { Product } from "../product.types"

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

type ProductGeneralInfoTableProps = {
  product: Product
}

const ProductGeneralInfoTable = ({ product }: ProductGeneralInfoTableProps) => {
  const { t: tDemands } = useTranslation(["demands"])
  const [readMore, setReadMore] = useState(true)
  const company = product?.company
  const companySlug = company?.slug || ""
  const productId = product?.id || ""

  return (
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
                numberOfDemandsPerDay: product.averageSpeed.toFixed(2),
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
  )
}

export default ProductGeneralInfoTable

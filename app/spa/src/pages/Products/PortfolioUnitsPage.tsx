import {
  Backdrop,
  CircularProgress,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
} from "@mui/material"
import BasicPage from "../../components/BasicPage"
import { useParams } from "react-router-dom"
import { useTranslation } from "react-i18next"
import useProductQuery from "../../hooks/useProductQuery"
import { formatCurrency } from "../../lib/currency"

const PortfolioUnitsPage = () => {
  const params = useParams()
  const { t } = useTranslation(["products"])
  const productSlug = params.productSlug || ""
  const { product, loading } = useProductQuery(productSlug)
  const productName = product?.name || ""
  const company = product?.company
  const companyName = company?.name || ""
  const companySlug = params.companySlug || ""

  const breadcrumbsLinks = [
    { name: companyName, url: `/companies/${companySlug}` },
    {
      name: t("products.title"),
      url: `/companies/${companySlug}/products`,
    },
    {
      name: productName,
      url: `/companies/${companySlug}/products/${productSlug}`,
    },
  ]

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      title={t("portfolioUnits.title")}
    >
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>{t("portfolioUnits.parent")}</TableCell>
            <TableCell>{t("portfolioUnits.portfolioUnitType")}</TableCell>
            <TableCell>{t("portfolioUnits.name")}</TableCell>
            <TableCell>{t("portfolioUnits.totalCost")}</TableCell>
            <TableCell>{t("portfolioUnits.totalHours")}</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {product?.portfolioUnits.map((unit) => {
            return (
              <TableRow>
                <TableCell>{unit.parent?.name}</TableCell>
                <TableCell>{unit.portfolioUnitTypeName}</TableCell>
                <TableCell>{unit.name}</TableCell>
                <TableCell>{formatCurrency(unit.totalCost ?? 0)}</TableCell>
                <TableCell>{unit.totalHours?.toFixed(2)}</TableCell>
              </TableRow>
            )
          })}
        </TableBody>
      </Table>
    </BasicPage>
  )
}

export default PortfolioUnitsPage
import {
  Backdrop,
  Box,
  Button,
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
import { Link as RouterLink } from "react-router-dom"

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
      <Box>
        <Box sx={{ display: "flex", justifyContent: "flex-end", mb: 3, mr: 3 }}>
          <Button
            component={RouterLink}
            to={`/companies/${companySlug}/products/${productSlug}/portfolio_units/new`}
            variant="contained"
          >
            {t("create_portfolio_units_button")}
          </Button>
        </Box>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>{t("portfolioUnits.parent")}</TableCell>
              <TableCell>{t("portfolioUnits.portfolioUnitType")}</TableCell>
              <TableCell>{t("portfolioUnits.name")}</TableCell>
              <TableCell>{t("portfolioUnits.totalCost")}</TableCell>
              <TableCell>{t("portfolioUnits.totalHours")}</TableCell>
              <TableCell></TableCell>
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
                  <TableCell>
                    {unit.totalHours?.toFixed(2)}
                  </TableCell>
                  <TableCell>
                  <Box sx={{ display: "flex", justifyContent: "flex-end", mb: 3, mr: 3 }}>
                      <Button
                        component={RouterLink}
                        to={`/companies/${companySlug}/products/${productSlug}/portfolio_units/${unit?.id}/edit`}
                        variant="contained"
                      >
                        Editar
                      </Button>
                    </Box>
                  </TableCell>
                </TableRow>
              )
            })}
          </TableBody>
        </Table>
      </Box>
    </BasicPage>
  )
}

export default PortfolioUnitsPage

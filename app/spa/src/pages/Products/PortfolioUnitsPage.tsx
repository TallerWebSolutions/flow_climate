import {
  Box,
  Button,
  FormGroup,
  Input,
  InputLabel,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
} from "@mui/material"
import BasicPage from "../../components/BasicPage"
import { Link as RouterLink, useParams } from "react-router-dom"
import { useTranslation } from "react-i18next"
import { formatCurrency } from "../../lib/currency"
import { gql, useQuery } from "@apollo/client"
import { Product } from "../../modules/product/product.types"
import { FormElement } from "../../components/ui/Form"
import { FieldValues, useForm } from "react-hook-form"
import SearchIcon from "@mui/icons-material/Search"

const PortfolioUnitsPage = () => {
  const params = useParams()
  const { t } = useTranslation(["products"])
  const { t: commonT } = useTranslation(["common"])
  const { register, handleSubmit } = useForm()

  const productSlug = params.productSlug || ""
  const { data, loading, variables, refetch } = useQuery<PortfolioUnitsDTO>(
    PORTFOLIO_UNITS_QUERY,
    {
      variables: { slug: productSlug },
      notifyOnNetworkStatusChange: true,
    }
  )

  const product = data?.product
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

  const setCostPeriod = (data: FieldValues) =>
    refetch({
      ...variables,
      startDate: data.startDate.length ? data.startDate : null,
      endDate: data.endDate.length ? data.endDate : null,
    })

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      title={t("portfolioUnits.title")}
      loading={loading}
    >
      <Box>
        <Box
          sx={{
            display: "flex",
            justifyContent: "space-between",
            mb: 3,
            mr: 3,
          }}
        >
          <form onSubmit={handleSubmit(setCostPeriod)}>
            <FormGroup sx={{ display: "flex", gap: 2, flexDirection: "row" }}>
              <FormElement>
                <InputLabel htmlFor="startDate" shrink>
                  {commonT("startDate")}
                </InputLabel>
                <Input
                  type="date"
                  defaultValue={variables?.startDate}
                  {...register("startDate")}
                />
              </FormElement>
              <FormElement>
                <InputLabel htmlFor="endDate" shrink>
                  {commonT("endDate")}
                </InputLabel>
                <Input
                  type="date"
                  defaultValue={variables?.endtDate}
                  {...register("endDate")}
                />
              </FormElement>
              <FormElement>
                <Button sx={{ alignSelf: "flex-start" }} type="submit">
                  <SearchIcon fontSize="large" color="primary" />
                </Button>
              </FormElement>
            </FormGroup>
          </form>
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
            {product?.portfolioUnits?.map((unit) => {
              return (
                <TableRow>
                  <TableCell>{unit.parent?.name}</TableCell>
                  <TableCell>{unit.portfolioUnitTypeName}</TableCell>
                  <TableCell>{unit.name}</TableCell>
                  <TableCell>{formatCurrency(unit.totalCost ?? 0)}</TableCell>
                  <TableCell>{unit.totalHours?.toFixed(2)}</TableCell>
                  <TableCell>
                    <Box
                      sx={{
                        display: "flex",
                        justifyContent: "flex-end",
                        mb: 3,
                        mr: 3,
                      }}
                    >
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

const PORTFOLIO_UNITS_QUERY = gql`
  query PortfolioUnits(
    $slug: String!
    $startDate: ISO8601Date
    $endDate: ISO8601Date
  ) {
    product(slug: $slug) {
      id
      portfolioUnits {
        id
        name
        totalCost(startDate: $startDate, endDate: $endDate)
        totalHours(startDate: $startDate, endDate: $endDate)
        portfolioUnitTypeName
        parent {
          id
          name
        }
      }
    }
  }
`

type PortfolioUnitsDTO = {
  product?: Product
}

export default PortfolioUnitsPage

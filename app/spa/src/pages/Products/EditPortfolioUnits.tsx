import { Link, useNavigate, useParams } from "react-router-dom"
import BasicPage from "../../components/BasicPage"
import useProductQuery from "../../hooks/useProductQuery"
import { useTranslation } from "react-i18next"
import {
    Box,
    Button,
    FormControl,
    FormGroup,
    Input,
    InputLabel,
    Select,
} from "@mui/material"

import { FieldValues, useForm } from "react-hook-form"
import { gql, useMutation, useQuery } from "@apollo/client"
import { Product } from "../../modules/product/product.types"
import { PortfolioUnit } from '../../modules/product/portfolioUnit.types'
import { PRODUCT_QUERY } from "../../hooks/useProductQuery"

type ProductDTO = {
  product?: Product
  portfolioUnitById?: PortfolioUnit
  jiraPortfolioUnitById?: string
}

const PRODUCT_INFO_QUERY = gql`
  query ProductQuery($slug: String!, $id: ID!) {
    product(slug: $slug) {
      id
      portfolioUnits {
        id
        name
      }
    }
    portfolioUnitById(id: $id) {
      id
			name
      totalCost
      totalHours
      portfolioUnitTypeName
      parent {
        id
        name
      }
		}
    jiraPortfolioUnitById(id: $id)
  }
`

const PORTFOLIO_UNIT_MUTATION = gql`
  mutation PortfolioUnit(
    $parentId: ID
    $productId: ID!
    $unitId: ID!
    $name: String!
    $portfolioUnitType: String!
    $jiraMachineName: String!
  ) {
    updatePortfolioUnit(
      parentId: $parentId
      productId: $productId
      unitId: $unitId
      name: $name
      portfolioUnitType: $portfolioUnitType
      jiraMachineName: $jiraMachineName
    ) {
      statusMessage
    }
  }
`

const EditPortfolioUnits = () => {
    const { register, handleSubmit } = useForm()
    const navigate = useNavigate()
    const params = useParams()
    const { t } = useTranslation(["products"])
    const productSlug = params.productSlug || ""
    const { product } = useProductQuery(productSlug)
    const productName = product?.name || ""
    const company = product?.company
    const companyName = company?.name || ""
    const companySlug = params.companySlug || ""
    const unitId = params.unitId || ""
    const portfolioUnitsUrl = `/companies/${companySlug}/products/${productSlug}/portfolio_units`

    const { data, loading } = useQuery<ProductDTO>(PRODUCT_INFO_QUERY, {
        variables: {
          slug: productSlug,
          id: unitId
        },
      })

      const portfolioUnits = data?.product?.portfolioUnits
      const actualPortfolioData = data?.portfolioUnitById
      const unitAncestral = actualPortfolioData?.parent?.id || ''
      const unitName = actualPortfolioData?.name || ''
      const unitType = 
      actualPortfolioData?.portfolioUnitTypeName || ''
      const unitMachineName = data?.jiraPortfolioUnitById || ''
      
      const breadcrumbsLinks = [
        { name: "Home", url: "/" },
        { name: companyName, url: `/companies/${companySlug}` },
        {
          name: productName,
          url: `/companies/${companySlug}/products/${productSlug}`,
        },
        {
          name: t("portfolioUnits.portfolioUnits"),
          url: `/companies/${companySlug}/products/${productSlug}/portfolio_units`,
        },
        {
          name: t("portfolioUnits.new"),
        },
      ]

      const [updatePortfolioUnit, { loading: mutationLoading }] = useMutation(
        PORTFOLIO_UNIT_MUTATION,
        {
          refetchQueries: [
            {
              query: PRODUCT_QUERY,
              variables: {
                slug: productSlug,
              },
            },
          ],
          update: () =>
            navigate(
              `/companies/${companySlug}/products/${productSlug}/portfolio_units`
            ),
        }
      )

      const handlePortfolioUnitSubmit = (data: FieldValues) => {
        updatePortfolioUnit({
          variables: {
            parentId: data.parentId,
            productId: product?.id,
            unitId: unitId,
            name: data.name,
            portfolioUnitType: data.unitType,
            jiraMachineName: data.machineName,
          },
        })
      }
      
      return (
        <BasicPage
          breadcrumbsLinks={breadcrumbsLinks}
          loading={loading || mutationLoading}
        >
          <Box sx={{ paddingY: 4 }}>
          <form onSubmit={handleSubmit(handlePortfolioUnitSubmit)}>
              <FormGroup
                sx={{
                  display: "grid",
                  gridTemplateColumns: "repeat(4, 1fr)",
                  gridColumnGap: "30px",
                }}
              >
                <FormControl sx={{ marginBottom: 4 }}>
                  <InputLabel htmlFor="parentId">
                    {t("portfolioUnits.fields.ancestral")}
                  </InputLabel>
                  <Select defaultValue={unitAncestral} native {...register("parentId")}>
                    <option value="" />
                    {portfolioUnits?.map(unit => (
                      <option value={unit.id}>{unit.name}</option>
                    ))}
                  </Select>
                </FormControl>
                <FormControl sx={{ marginBottom: 4 }}>
                  <InputLabel htmlFor="name">
                    {t("portfolioUnits.fields.name")}*
                  </InputLabel>
                  <Input defaultValue={unitName} {...register("name", { required: true })} />
                </FormControl>
                <FormControl sx={{ marginBottom: 4 }}>
                  <InputLabel htmlFor="unitType">
                    {t("portfolioUnits.fields.unitType")}
                  </InputLabel>
                  <Select 
                  defaultValue={getUnitType(unitType)} 
                  native 
                  {...register("unitType")}
                  >
                    <option value="product_module">
                      {t("portfolioUnits.fields.options.unitType.productModule")}
                    </option>
                    <option value="journey_stage">
                      {t("portfolioUnits.fields.options.unitType.journeyStage")}
                    </option>
                    <option value="theme">
                      {t("portfolioUnits.fields.options.unitType.theme")}
                    </option>
                    <option value="epic">
                      {t("portfolioUnits.fields.options.unitType.epic")}
                    </option>
                  </Select>
                </FormControl>
                <FormControl sx={{ marginBottom: 4 }}>
                  <InputLabel htmlFor="machineName">
                    {t("portfolioUnits.fields.machineName")}
                  </InputLabel>
                  <Input
                    defaultValue={unitMachineName}
                    {...register("machineName")}
                    placeholder={unitMachineName !== '' ?  unitMachineName : 'customfield_10052'}
                  />
                </FormControl>
              </FormGroup>
              <Box sx={{ display: "flex", justifyContent: "flex-start" }}>
                <Button variant="contained" sx={{ marginRight: 2 }} type="submit">
                  {t("portfolioUnits.form.save")}
                </Button>
                <Button variant="outlined" component={Link} to={portfolioUnitsUrl}>
                  {t("portfolioUnits.form.cancel")}
                </Button>
              </Box>
            </form>
          </Box>
        </BasicPage>
      )
}

export default EditPortfolioUnits

const getUnitType = (value: string) => {
  let result = ''
  switch (value) {
    case 'Modulo de Produto':
      result =  'product_module'
    break
    case 'Etapa da Jornada':
      result =  'journey_stage'
    break
    case 'Tema':
      result = 'theme'
    break
    case 'Épico':
      result = 'epic'
    break
    default:
      result =  'product_module'
  }

  return result
}


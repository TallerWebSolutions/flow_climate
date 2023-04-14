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

type ProductDTO = {
  product?: Product
}

const PRODUCT_QUERY = gql`
  query ProductQuery($slug: String!) {
    product(slug: $slug) {
      id
      portfolioUnits {
        id
        name
      }
    }
  }
`

const PORTFOLIO_UNIT_MUTATION = gql`
  mutation PortfolioUnit(
    $parentId: ID
    $productId: ID!
    $name: String!
    $portfolioUnitType: String!
    $jiraMachineName: String!
  ) {
    createPortfolioUnit(
      parentId: $parentId
      productId: $productId
      name: $name
      portfolioUnitType: $portfolioUnitType
      jiraMachineName: $jiraMachineName
    ) {
      statusMessage
      portfolioUnit {
        name
      }
    }
  }
`

const CreatePortfolioUnits = () => {
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
  const portfolioUnitsUrl = `/companies/${companySlug}/products/${productSlug}/portfolio_units`

  const { data, loading } = useQuery<ProductDTO>(PRODUCT_QUERY, {
    variables: {
      slug: productSlug,
    },
  })

  const portfolioUnits = data?.product?.portfolioUnits

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

  const [createPortfolioUnit, { loading: mutationLoading }] = useMutation(
    PORTFOLIO_UNIT_MUTATION,
    {
      update: () =>
        navigate(
          `/companies/${companySlug}/products/${productSlug}/portfolio_units`
        ),
    }
  )

  const handlePortfolioUnitSubmit = (data: FieldValues) => {
    createPortfolioUnit({
      variables: {
        parentId: data.parentId,
        productId: product?.id,
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
              <Select native {...register("parentId")}>
                <option value="" />
                {portfolioUnits?.map((unit) => (
                  <option value={unit.id}>{unit.name}</option>
                ))}
              </Select>
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="name">
                {t("portfolioUnits.fields.name")}*
              </InputLabel>
              <Input {...register("name", { required: true })} />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="unitType">
                {t("portfolioUnits.fields.unitType")}
              </InputLabel>
              <Select native {...register("unitType")}>
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
              <Input {...register("machineName")} />
            </FormControl>
            <Box sx={{ display: "flex", justifyContent: "flex-start" }}>
              <Button type="submit" variant="contained" sx={{ marginRight: 2 }}>
                {t("portfolioUnits.form.save")}
              </Button>
              <Button
                variant="outlined"
                component={Link}
                to={portfolioUnitsUrl}
              >
                {t("portfolioUnits.form.cancel")}
              </Button>
            </Box>
          </FormGroup>
        </form>
      </Box>
    </BasicPage>
  )
}

export default CreatePortfolioUnits

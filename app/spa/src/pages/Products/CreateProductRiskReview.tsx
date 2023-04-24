import { gql, useMutation, useQuery } from "@apollo/client"
import {
  Button,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
} from "@mui/material"
import { FieldValues, useForm } from "react-hook-form"
import { useTranslation } from "react-i18next"
import { useNavigate, useParams } from "react-router-dom"

import BasicPage from "../../components/BasicPage"
import { Product, RiskReview } from "../../modules/product/product.types"

const PRODUCT_QUERY = gql`
  query CreateProductRiskReviewQuery($productSlug: String!) {
    product(slug: $productSlug) {
      id
      slug
      name
      company {
        id
        slug
        name
      }
    }
  }
`

type ProductDTO = {
  product?: Product
}

const CREATE_PRODUCT_RISK_REVIEW_MUTATION = gql`
  mutation CreateProductRiskReview(
    $companyId: ID!
    $productId: ID!
    $leadTimeOutlierLimit: Float!
    $meetingDate: ISO8601Date!
  ) {
    createProductRiskReview(
      companyId: $companyId
      productId: $productId
      leadTimeOutlierLimit: $leadTimeOutlierLimit
      meetingDate: $meetingDate
    ) {
      riskReview {
        id
        company {
          id
          slug
        }
        product {
          id
          slug
        }
      }
    }
  }
`

type CreateProductRiskReviewDTO = {
  riskReview?: RiskReview
}

const CreateProductRiskReview = () => {
  const { productSlug } = useParams()
  const { t } = useTranslation("riskReview")
  const navigate = useNavigate()
  const { data, loading } = useQuery<ProductDTO>(PRODUCT_QUERY, {
    variables: { productSlug },
    notifyOnNetworkStatusChange: true,
  })
  const product = data?.product
  const company = product?.company
  const [createProductRiskReview] = useMutation<CreateProductRiskReviewDTO>(
    CREATE_PRODUCT_RISK_REVIEW_MUTATION,
    {
      update: () =>
        navigate(
          `/companies/${company?.slug}/products/${product?.slug}/risk_reviews_tab`
        ),
    }
  )
  const { register, handleSubmit } = useForm()

  const breadcrumbsLinks = [
    { name: company?.name || "", url: `/companies/${company?.slug}` },
    {
      name: t("new.products"),
      url: `/companies/${company?.slug}/products`,
    },
    {
      name: product?.name || "",
      url: `/companies/${company?.slug}/products/${product?.slug}`,
    },
    {
      name: t("new.title"),
      url: `/companies/${company?.slug}/products/${product?.slug}/risk_reviews_tab`,
    },
    {
      name: t("new.title"),
    },
  ]

  const handleCreateProductRiskReview = (data: FieldValues) => {
    const { leadTimeOutlierLimit, meetingDate } = data

    createProductRiskReview({
      variables: {
        companyId: company?.id,
        productId: product?.id,
        leadTimeOutlierLimit: Number(leadTimeOutlierLimit),
        meetingDate,
      },
    })
  }

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
      title={t("new.title")}
    >
      <form onSubmit={handleSubmit(handleCreateProductRiskReview)}>
        <FormGroup
          sx={{
            display: "grid",
            gridTemplateColumns: "repeat(3, 1fr)",
            gridColumnGap: "30px",
          }}
        >
          <FormControl>
            <InputLabel htmlFor="leadTimeOutlierLimit">
              {t("new.leadTimeOutlierLimit")} *
            </InputLabel>

            <Input type="number" {...register("leadTimeOutlierLimit")} />
          </FormControl>
          <FormControl>
            <InputLabel shrink htmlFor="meetingDate">
              {t("new.meetingDate")} *
            </InputLabel>
            <Input
              {...register("meetingDate", { required: true })}
              type="date"
            />
          </FormControl>
        </FormGroup>

        <Button sx={{ mt: 2 }} variant="contained" type="submit">
          {t("new.create")}
        </Button>
      </form>
    </BasicPage>
  )
}

export default CreateProductRiskReview

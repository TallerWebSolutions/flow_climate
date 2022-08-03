import { gql, useMutation, useQuery } from "@apollo/client"
import {
  Box,
  Button,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
  Select,
} from "@mui/material"
import { useContext } from "react"
import { FieldValues, useForm } from "react-hook-form"
import { useTranslation } from "react-i18next"
import { Link, useParams } from "react-router-dom"

import BasicPage from "../../components/BasicPage"
import { MeContext } from "../../contexts/MeContext"
import { Initiative } from "../../modules/initiative/initiative.types"

const INITIATIVE_FRAGMENT = gql`
  fragment initiativeFragment on Initiative {
    id
    name
    endDate
    startDate
    targetQuarter
    targetYear
  }
`

const INITIATIVE_QUERY = gql`
  query EditInitiativeQuery($initiativeId: ID!) {
    initiative(initiativeId: $initiativeId) {
      ...initiativeFragment
    }
  }

  ${INITIATIVE_FRAGMENT}
`

const EDIT_INITIATIVE_MUTATION = gql`
  mutation EditInitiative(
    $initiativeId: ID!
    $name: String!
    $endDate: ISO8601Date!
    $startDate: ISO8601Date!
    $targetQuarter: TargetQuarter!
    $targetYear: Int!
  ) {
    updateInitiative(
      initiativeId: $initiativeId
      name: $name
      endDate: $endDate
      startDate: $startDate
      targetQuarter: $targetQuarter
      targetYear: $targetYear
    ) {
      initiative {
        ...initiativeFragment
      }
    }
  }

  ${INITIATIVE_FRAGMENT}
`

type InitiativeDTO = {
  initiative: Initiative
}

const EditInitiative = () => {
  const { me } = useContext(MeContext)
  const { initiativeId } = useParams()
  const { register, handleSubmit } = useForm()
  const { t } = useTranslation("initiatives")
  const { data, loading } = useQuery<InitiativeDTO>(INITIATIVE_QUERY, {
    variables: { initiativeId },
  })
  const [editInitiative, { loading: mutationLoading }] = useMutation(
    EDIT_INITIATIVE_MUTATION
  )

  const company = me?.currentCompany
  const companySlug = company?.slug
  const initiative = data?.initiative
  const initiativesUrl = `/companies/${companySlug}/initiatives`
  const breadcrumbsLinks = [
    {
      name: company?.name || "",
      url: `/companies/${companySlug}`,
    },
    {
      name: t("initiatives"),
      url: initiativesUrl,
    },
    {
      name: initiative?.name || "",
      url: `/companies/${companySlug}/initiatives/${initiative?.id}`,
    },
    {
      name: t("edit"),
    },
  ]
  const pageTitle = `${t("edit")} ${initiative?.name}`

  const handleEditInitiative = (data: FieldValues) =>
    editInitiative({
      variables: { ...data, initiativeId, targetYear: Number(data.targetYear) },
    })

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading || mutationLoading}
      title={pageTitle}
    >
      <Box sx={{ maxWidth: "480px", marginX: "auto", paddingY: 4 }}>
        <form onSubmit={handleSubmit(handleEditInitiative)}>
          <FormGroup>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="name">{t("form.name")}</InputLabel>
              <Input
                {...register("name", { required: true })}
                defaultValue={initiative?.name}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="startDate" shrink>
                {t("form.startDate")}
              </InputLabel>
              <Input
                {...register("startDate", { required: true })}
                type="date"
                defaultValue={initiative?.startDate}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="endDate" shrink>
                {t("form.endDate")}
              </InputLabel>
              <Input
                {...register("endDate")}
                type="date"
                defaultValue={initiative?.endDate}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="targetYear">
                {t("form.targetYear")}
              </InputLabel>

              <Input
                defaultValue={initiative?.targetYear}
                type="number"
                {...register("targetYear")}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel
                shrink
                sx={{ backgroundColor: "white" }}
                htmlFor="targetQuarter"
              >
                {t("form.targetQuarter")}
              </InputLabel>
              <Select
                native
                {...register("targetQuarter")}
                defaultValue={initiative?.targetQuarter}
              >
                <option value="q1">{t("form.firstQuarter")}</option>
                <option value="q2">{t("form.secondQuarter")}</option>
                <option value="q3">{t("form.thirdQuarter")}</option>
                <option value="q4">{t("form.fourthQuarter")}</option>
              </Select>
            </FormControl>
            <Box sx={{ display: "flex", justifyContent: "flex-start" }}>
              <Button type="submit" variant="contained" sx={{ marginRight: 2 }}>
                {t("form.save")}
              </Button>
              <Button variant="outlined" component={Link} to={initiativesUrl}>
                {t("form.cancel")}
              </Button>
            </Box>
          </FormGroup>
        </form>
      </Box>
    </BasicPage>
  )
}

export default EditInitiative

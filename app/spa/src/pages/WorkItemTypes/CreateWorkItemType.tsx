import { gql, useMutation } from "@apollo/client"
import {
  Box,
  Button,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
  Select,
  Checkbox,
  FormControlLabel,
} from "@mui/material"
import { useContext } from "react"
import { FieldValues, useForm } from "react-hook-form"
import { useTranslation } from "react-i18next"
import { Link, useNavigate } from "react-router-dom"

import BasicPage from "../../components/BasicPage"
import { MeContext } from "../../contexts/MeContext"

const CREATE_WORK_ITEM_TYPE = gql`
  mutation CreateWorkItemType(
    $name: String!
    $itemLevel: WorkItemLevel!
    $qualityIndicatorType: Boolean!
  ) {
    createWorkItemType(
      name: $name
      itemLevel: $itemLevel
      qualityIndicatorType: $qualityIndicatorType
    ) {
      workItemType {
        id
        name
        itemLevel
        qualityIndicatorType
      }
    }
  }
`

const CreateWorkItemType = () => {
  const { me } = useContext(MeContext)
  const { t } = useTranslation("workItemTypes")
  const { register, handleSubmit } = useForm()
  const navigate = useNavigate()

  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const workItemTypesUrl = `${companyUrl}/work_item_types`
  const [createWorkItemType, { loading }] = useMutation(CREATE_WORK_ITEM_TYPE, {
    onCompleted: () => navigate(workItemTypesUrl),
  })
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("title"),
    },
  ]

  const handleCreateWorkItemType = (data: FieldValues) =>
    createWorkItemType({
      variables: data,
    })

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      title={t("title")}
      loading={loading}
    >
      <form onSubmit={handleSubmit(handleCreateWorkItemType)}>
        <FormGroup>
          <FormControl sx={{ marginBottom: 4 }}>
            <InputLabel htmlFor="name">{t("form.name")}</InputLabel>
            <Input {...register("name", { required: true })} />
          </FormControl>
          <FormControl sx={{ marginBottom: 4 }}>
            <InputLabel
              shrink
              sx={{ backgroundColor: "white" }}
              htmlFor="itemLevel"
            >
              {t("form.itemLevel")}
            </InputLabel>
            <Select native {...register("itemLevel")}>
              <option value="DEMAND">{t("form.demand")}</option>
            </Select>
          </FormControl>
          <FormControlLabel
            control={
              <Checkbox
                {...register("qualityIndicatorType")}
                defaultChecked={false}
              />
            }
            label={t("form.qualityIndicatorType")}
            sx={{ marginBottom: 4 }}
          />
          <Box sx={{ display: "flex", justifyContent: "flex-start" }}>
            <Button type="submit" variant="contained" sx={{ marginRight: 2 }}>
              {t("form.save")}
            </Button>
            <Button variant="outlined" component={Link} to={workItemTypesUrl}>
              {t("form.cancel")}
            </Button>
          </Box>
        </FormGroup>
      </form>
    </BasicPage>
  )
}

export default CreateWorkItemType

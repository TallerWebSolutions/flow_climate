import { FormControl, FormGroup, Input, InputLabel } from "@mui/material"
import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { useForm } from "react-hook-form"

import BasicPage from "../../components/BasicPage"
import { MeContext } from "../../contexts/MeContext"

const EditTeamMember = () => {
  const { t } = useTranslation(["teamMembers"])
  const { me } = useContext(MeContext)
  const { register, handleSubmit } = useForm()

  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("list.title"),
      url: `${companyUrl}/team_members`,
    },
    {
      name: t("edit.title"),
    },
  ]

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks} title={t("edit.title")}>
      <form>
        <FormGroup>
          <FormControl>
            <InputLabel htmlFor="name">{t("edit.form.name")}</InputLabel>
            <Input {...register("name", { required: true })} />
          </FormControl>
        </FormGroup>
      </form>
    </BasicPage>
  )
}

export default EditTeamMember

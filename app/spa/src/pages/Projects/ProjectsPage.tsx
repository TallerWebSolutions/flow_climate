import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { MeContext } from "../../contexts/MeContext"
import ProjectsList from "../../modules/project/components/ProjectsList"

const ProjectsPage = () => {
  const { t } = useTranslation(["projects"])
  const { me } = useContext(MeContext)
  const companyUrl = `/companies/${me?.currentCompany?.slug}`

  const breadcrumbsLinks = [
    { name: "Home", url: "/" },
    { name: me?.currentCompany?.name || "", url: companyUrl },
    { name: t("projects") },
  ]

  return (
    <ProjectsList breadcrumbsLinks={breadcrumbsLinks} companyUrl={companyUrl} />
  )
}

export default ProjectsPage

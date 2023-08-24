import { Button } from "@mui/material"
import BasicPage, { BasicPageProps } from "../../../components/BasicPage"
import { useTranslation } from "react-i18next"
import { FieldValues } from "react-hook-form"
import { useSearchParams } from "react-router-dom"
import ProjectsTable from "./ProjectsTable"
import ProjectsSearchForm from "./ProjectsSearchForm"

type ProjectsListProps = {
  companyUrl: string
} & BasicPageProps

const ProjectsList = ({ companyUrl, ...props }: ProjectsListProps) => {
  const { t } = useTranslation(["projects"])

  const createNewProjectUrl = `${companyUrl}/projects/new`

  const [searchParams] = useSearchParams()

  const projectsFilters: FieldValues = {
    name: searchParams.get("name"),
    status: searchParams.get("status") || "executing",
    startDate: searchParams.get("startDate"),
    endDate: searchParams.get("endDate"),
  }

  return (
    <BasicPage {...props}>
      <ProjectsSearchForm projectsFilters={projectsFilters} />

      <Button
        variant="contained"
        href={createNewProjectUrl}
        sx={{ float: "right", marginBottom: "2rem" }}
      >
        {t("new.button.title")}
      </Button>

      <ProjectsTable projectsFilters={projectsFilters} />
    </BasicPage>
  )
}

export default ProjectsList

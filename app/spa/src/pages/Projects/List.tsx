import { gql, useQuery } from "@apollo/client"
import { useTranslation } from "react-i18next"
import { useContext, useEffect, useState } from "react"
import { MeContext } from "../../contexts/MeContext"
import { Project } from "../../modules/project/project.types"
import { ProjectsFilters } from "./Projects"
import {
  Backdrop,
  CircularProgress,
  Box,
  LinearProgress,
  styled,
  linearProgressClasses,
  Link,
  Typography,
} from "@mui/material"
import { Company } from "../../modules/company/company.types"
import Table from "../../components/Table"

const PROJECT_LIST_QUERY = gql`
  query projectList(
    $companyId: Int!
    $name: String
    $status: String
    $startDate: ISO8601Date
    $endDate: ISO8601Date
  ) {
    projects(
      companyId: $companyId
      name: $name
      status: $status
      startDate: $startDate
      endDate: $endDate
    ) {
      id
      name
      team {
        id
        name
      }
      status
      numberOfDemands
      remainingDays
      numberOfDemandsDelivered
      qtyHours
      consumedHours
      currentRiskToDeadline
      startDate
      endDate
    }
  }
`

type ProjectListDTO = {
  projects: Project[]
}

type ProjectsListProps = {
  filters: ProjectsFilters
  setFilters: React.Dispatch<React.SetStateAction<ProjectsFilters>>
}

const ProjectsList = ({ filters, setFilters }: ProjectsListProps) => {
  const { t } = useTranslation(["projects"])
  const [company, setCompany] = useState<Company | null>(null)
  const [projects, setProjects] = useState<Project[]>([])

  const { me } = useContext(MeContext)
  const companyId = Number(company?.id)
  const companyUrl = `/companies/${company?.slug}`

  const { data, loading } = useQuery<ProjectListDTO>(PROJECT_LIST_QUERY, {
    variables: {
      companyId,
      ...filters,
    },
  })

  useEffect(() => {
    if (!loading) {
      setProjects(data?.projects ?? [])
      setCompany(me?.currentCompany!)
    }
  }, [data, loading, me?.currentCompany])

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const BorderLinearProgress = styled(LinearProgress)(({ theme }) => ({
    height: 10,
    borderRadius: 5,
    [`&.${linearProgressClasses.colorPrimary}`]: {
      backgroundColor:
        theme.palette.grey[theme.palette.mode === "light" ? 200 : 800],
    },
    [`& .${linearProgressClasses.bar}`]: {
      borderRadius: 5,
      backgroundColor: theme.palette.mode === "light" ? "#1a90ff" : "#308fe8",
    },
  }))

  const cosumedHoursInPercentage = (
    consumedHours: number,
    qtyHours: number
  ) => {
    const result = Math.floor((consumedHours / qtyHours) * 100)

    return result > 100 ? 100 : result
  }

  const projectsListHeaderCells = [
    t("projects_table.name"),
    t("projects_table.team"),
    t("projects_table.status"),
    t("projects_table.demands"),
    t("projects_table.remaing_days"),
    t("projects_table.delivered"),
    t("projects_table.qty_hours"),
    t("projects_table.risk"),
  ]

  const projectList =
    projects.map((project) => [
      <Link href={`${companyUrl}/projects/${project.id}`}>{project.name}</Link>,
      <Link href={`${companyUrl}/teams/${project.team?.id}`}>
        {project.team?.name}
      </Link>,
      project.status,
      `${project.numberOfDemands} ${t("projects_table.row_demands")}`,
      `${project.remainingDays} ${t("projects_table.row_days")}`,
      `${project.numberOfDemandsDelivered} ${t(
        "projects_table.row_delivered"
      )}`,
      <Box>
        <>
          {project.qtyHours}h {t("projects_table.row_total")}
        </>
        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: "repeat(2, 1fr)",
            gap: 1,
            alignItems: "center",
          }}
        >
          <BorderLinearProgress
            variant="determinate"
            value={cosumedHoursInPercentage(
              project.consumedHours,
              project.qtyHours
            )}
          />
          <Typography
            variant="subtitle2"
            component="span"
            sx={{ color: "gray.600" }}
          >
            {`${project.consumedHours.toFixed(2)}h ${t(
              "projects_table.row_consumed"
            )}`}
          </Typography>
        </Box>
      </Box>,
      `${(project.currentRiskToDeadline || 0 * 100).toFixed(2)}%`,
    ]) || []

  return <Table headerCells={projectsListHeaderCells} rows={projectList} />
}

export default ProjectsList

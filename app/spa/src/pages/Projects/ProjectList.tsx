import { gql, useQuery } from "@apollo/client"
import { useContext } from "react"
import { MeContext } from "../../contexts/MeContext"
import {
  Backdrop,
  Button,
  CircularProgress,
  Link,
  Box,
  LinearProgress,
  styled,
  linearProgressClasses,
  Typography,
} from "@mui/material"
import BasicPage from "../../components/BasicPage"
import { Project } from "../../modules/project/project.types"
import Table from "../../components/Table"
import { useTranslation } from "react-i18next"

const PROJECT_LIST_QUERY = gql`
  query projectList($companyId: Int!) {
    projects(companyId: $companyId) {
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
    }
  }
`

type ProjectListDTO = {
  projects: Pick<
    Project,
    | "id"
    | "name"
    | "team"
    | "status"
    | "numberOfDemands"
    | "remainingDays"
    | "numberOfDemandsDelivered"
    | "qtyHours"
    | "consumedHours"
    | "currentRiskToDeadline"
  >[]
}

const ProjectList = () => {
  const { t } = useTranslation(["projects"])
  const { me } = useContext(MeContext)
  const companyId = me?.currentCompany?.id
  const { data, loading } = useQuery<ProjectListDTO>(PROJECT_LIST_QUERY, {
    variables: {
      companyId: Number(companyId),
    },
  })
  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const createNewProjectUrl = `${companyUrl}/projects/new`

  const breadcrumbsLinks = [
    { name: "Home", url: "/" },
    { name: me?.currentCompany?.name || "", url: companyUrl },
    { name: t("projects") },
  ]

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

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

  const projectList =
    data?.projects.map((project) => [
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
      `${(project.currentRiskToDeadline * 100).toFixed(2)}%`,
    ]) || []

  return (
    <BasicPage title={t("projects")} breadcrumbsLinks={breadcrumbsLinks}>
      <Button
        variant="contained"
        href={createNewProjectUrl}
        sx={{ float: "right", marginBottom: "2rem" }}
      >
        New Project
      </Button>

      <Table headerCells={projectsListHeaderCells} rows={projectList} />
    </BasicPage>
  )
}

export default ProjectList

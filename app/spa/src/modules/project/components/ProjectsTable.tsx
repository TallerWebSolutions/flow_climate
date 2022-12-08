import { gql, useQuery } from "@apollo/client"
import { TFunction, useTranslation } from "react-i18next"
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

import { MeContext } from "../../../contexts/MeContext"
import { Project } from "../project.types"
import Table, { RowWithCollapse } from "../../../components/ui/Table"
import DateLocale from "../../../components/ui/DateLocale"
import { FieldValues } from "react-hook-form"
import { useContext } from "react"
import { formatCurrency } from "../../../lib/currency"

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
      customersNames
      status
      numberOfDemands
      remainingDays
      numberOfDemandsDelivered
      qtyHours
      consumedHours
      percentageHoursDelivered
      currentRiskToDeadline
      startDate
      endDate
      value
      maxWorkInProgress
      team {
        id
        name
      }
    }
  }
`

type ProjectListDTO = {
  projects: Project[]
}

type ProjectsTableProps = {
  projectsFilters: FieldValues
}

const ProjectsTable = ({ projectsFilters }: ProjectsTableProps) => {
  const { t } = useTranslation("projects")

  const { me } = useContext(MeContext)
  const company = me?.currentCompany
  const companyId = Number(company?.id)

  const projectsQueryFilters = Object.keys(projectsFilters)
    .filter((key) => {
      return String(projectsFilters[key]).length > 0
    })
    .reduce<Record<string, string>>((acc, el) => {
      return { ...acc, [el]: projectsFilters[el] }
    }, {})

  const { data, loading } = useQuery<ProjectListDTO>(PROJECT_LIST_QUERY, {
    variables: {
      companyId,
      ...projectsQueryFilters,
    },
  })

  const projects = data?.projects || []

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const projectRowWithCollapse = (project: Project) => {
    const company = project.company
    const companyUrl = `/companies/${company?.slug}`
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

    return {
      rowInfo: [
        <Link
          maxWidth={250}
          display="inline-block"
          href={`${companyUrl}/projects/${project.id}`}
        >
          {project.name}
        </Link>,
        <Link href={`${companyUrl}/teams/${project.team?.id}`}>
          {project.team?.name}
        </Link>,
        project.status,
        <DateLocale date={project.startDate} />,
        <DateLocale date={project.endDate} />,
        `${project.numberOfDemands} ${t("projectsTable.row_demands")}`,
        `${project.remainingDays} ${t("projectsTable.row_days")}`,
        `${project.numberOfDemandsDelivered} ${t(
          "projectsTable.row_delivered"
        )}`,
        <Box>
          <>
            {project.qtyHours}h {t("projectsTable.row_total")}
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
              value={project.percentageHoursDelivered * 100}
            />
            <Typography
              variant="subtitle2"
              component="span"
              sx={{ color: "gray.600" }}
            >
              {`${project.consumedHours.toFixed(2)}h ${t(
                "projectsTable.row_consumed"
              )}`}
            </Typography>
          </Box>
        </Box>,
        `${((project.currentRiskToDeadline || 0) * 100).toFixed(2)}%`,
      ],
      collapseInfo: {
        collapseHeader: [
          t("projectsTable.customers"),
          t("projectsTable.value"),
          t("projectsTable.maxWorkInProgress"),
        ],
        collapseBody: [
          project.customersNames,
          formatCurrency(project.value),
          project.maxWorkInProgress,
        ],
      },
    }
  }

  const projectsListHeaderCells = [
    "",
    t("projectsTable.name"),
    t("projectsTable.team"),
    t("projectsTable.status"),
    t("projectsTable.startDate"),
    t("projectsTable.endDate"),
    t("projectsTable.demands"),
    t("projectsTable.remaingDays"),
    t("projectsTable.delivered"),
    t("projectsTable.qty_hours"),
    t("projectsTable.risk"),
  ]

  const projectsRows: RowWithCollapse[] =
    projects.map(projectRowWithCollapse) || []

  return (
    <Table
      headerCells={projectsListHeaderCells}
      rows={projectsRows}
      withCollapse={true}
    />
  )
}

export default ProjectsTable

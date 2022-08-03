import { gql, useQuery } from "@apollo/client"
import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { Link as RouterLink } from "react-router-dom"
import { Button, Link } from "@mui/material"
import EditOutlinedIcon from "@mui/icons-material/EditOutlined"

import { MeContext } from "../../contexts/MeContext"
import BasicPage from "../../components/BasicPage"
import Table from "../../components/ui/Table"
import { Initiative } from "../../modules/initiative/initiative.types"
import { formatDate } from "../../lib/date"

type InitiativeListDTO = {
  initiatives: Initiative[]
}

const INITIATIVES_LIST_QUERT = gql`
  query initiativesList($companyId: Int!) {
    initiatives(companyId: $companyId) {
      id
      name
      startDate
      endDate
      currentTasksOperationalRisk
      projectsCount
      demandsCount
      tasksCount
      tasksFinishedCount
      remainingBacklogTasksPercentage
    }
  }
`

const InitiativesList = () => {
  const { t } = useTranslation("initiatives")
  const { me } = useContext(MeContext)
  const companyId = me?.currentCompany?.id
  const { data, loading } = useQuery<InitiativeListDTO>(
    INITIATIVES_LIST_QUERT,
    {
      variables: {
        companyId: Number(companyId),
      },
    }
  )
  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const createInitiativeUrl = `${companyUrl}/initiatives/new`

  const breadcrumbsLinks = [
    { name: "Home", url: "/" },
    { name: me?.currentCompany?.name || "", url: companyUrl },
    { name: t("initiatives") },
  ]

  const initiativesListHeaderCells = [
    t("initiatives_list_table.name"),
    t("initiatives_list_table.start_date"),
    t("initiatives_list_table.end_date"),
    t("initiatives_list_table.operational_risk"),
    t("initiatives_list_table.projects"),
    t("initiatives_list_table.demands"),
    t("initiatives_list_table.tasks"),
    t("initiatives_list_table.deliveries"),
    t("initiatives_list_table.actions"),
  ]

  const initiativesRows =
    data?.initiatives.map((initiative) => [
      <Link href={`${companyUrl}/initiatives/${initiative.id}`}>
        {initiative.name}
      </Link>,
      formatDate({ date: initiative.startDate }),
      formatDate({ date: initiative.endDate }),
      `${(initiative.currentTasksOperationalRisk * 100).toFixed(2)}%`,
      initiative.projectsCount,
      initiative.demandsCount,
      initiative.tasksCount,
      initiative.tasksFinishedCount,
      <RouterLink to={`${companyUrl}/initiatives/${initiative.id}/edit`}>
        <EditOutlinedIcon color="primary" />
      </RouterLink>,
    ]) || []

  return (
    <BasicPage
      title={t("initiatives")}
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
    >
      <Button
        variant="contained"
        href={createInitiativeUrl}
        sx={{ float: "right", marginBottom: "2rem" }}
      >
        {t("create_initiatives_button")}
      </Button>
      <Table headerCells={initiativesListHeaderCells} rows={initiativesRows} />
    </BasicPage>
  )
}

export default InitiativesList

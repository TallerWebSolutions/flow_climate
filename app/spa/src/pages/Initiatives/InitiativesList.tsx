import { Button } from "@mui/material"
import { useContext } from "react"
import { useTranslation } from "react-i18next"
import BasicPage from "../../components/BasicPage"
import Table from "../../components/Table"
import { MeContext } from "../../contexts/MeContext"

const InitiativesList = () => {
  const { t } = useTranslation(["initiatives"])
  const { me } = useContext(MeContext)
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
  ]

  return (
    <BasicPage title={t("initiatives")} breadcrumbsLinks={breadcrumbsLinks}>
      <Button
        variant="contained"
        href={createInitiativeUrl}
        sx={{ float: "right", marginBottom: "2rem" }}
      >
        {t("create_initiatives_button")}
      </Button>
      <Table headerCells={initiativesListHeaderCells} rows={[]} />
    </BasicPage>
  )
}

export default InitiativesList

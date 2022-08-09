import { gql, useQuery } from "@apollo/client"
import CheckIcon from "@mui/icons-material/Check"
import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { Link } from "react-router-dom"
import { Button } from "@mui/material"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/ui/Table"
import { MeContext } from "../../contexts/MeContext"

const WORK_ITEM_TYPES = gql`
  query WorkItemTypesList {
    workItemTypes {
      id
      name
      qualityIndicatorType
      itemLevel
    }
  }
`

type WorkItemType = {
  id: string
  name: string
  qualityIndicatorType: boolean
  itemLevel: string
}

type WorkItemTypesDTO = {
  workItemTypes: WorkItemType[]
}

const ListWorkItemTypes = () => {
  const { data, loading } = useQuery<WorkItemTypesDTO>(WORK_ITEM_TYPES)
  const { t } = useTranslation("workItemTypes")
  const { me } = useContext(MeContext)

  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("table.title"),
    },
  ]
  const headerCells = [
    t("table.name"),
    t("table.qualityIndicatorType"),
    t("table.itemLevel"),
  ]
  const workItemTypesRows =
    data?.workItemTypes.map((itemType) => [
      itemType.name,
      itemType.qualityIndicatorType ? <CheckIcon color="primary" /> : "",
      itemType.itemLevel,
    ]) || []

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks} loading={loading}>
      <Button
        component={Link}
        variant="contained"
        to={`${companyUrl}/work_item_types/new`}
        sx={{ float: "right", marginBottom: "2rem" }}
      >
        {t("table.create")}
      </Button>
      <Table
        rows={workItemTypesRows}
        headerCells={headerCells}
        title={t("table.title")}
      />
    </BasicPage>
  )
}

export default ListWorkItemTypes

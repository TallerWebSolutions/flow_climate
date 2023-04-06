import { gql, useQuery } from "@apollo/client"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import EditIcon from "@mui/icons-material/Edit"
import CheckIcon from "@mui/icons-material/Check"
import { Link } from "@mui/material"

import DateLocale from "../../components/ui/DateLocale"
import Table from "../../components/ui/Table"
import DemandBasicPage from "../../modules/demand/components/DemandBasicPage"
import { Demand as DemandType } from "../../modules/demand/demand.types"

const DEMAND_QUERY = gql`
  query Demand($externalId: String!) {
    demand(externalId: $externalId) {
      id
      demandTitle
      externalId
      effortUpstream
      effortDownstream
      costToProject
      demandEfforts {
        id
        effortValue
        effortMoney
        startTimeToComputation
        finishTimeToComputation
        stagePercentage
        pairingPercentage
        managementPercentage
        totalBlocked
        mainEffortInTransition
        stage
        who
        memberRole
        automaticUpdate
      }
    }
  }
`

type DemandDTO = {
  demand?: DemandType
}

const DemandEfforts = () => {
  const params = useParams()
  const { t } = useTranslation("demandEffort")

  const { data, loading } = useQuery<DemandDTO>(DEMAND_QUERY, {
    variables: { externalId: params?.demand },
  })

  const demand = data?.demand
  const tableHeader = [
    t("table.header.id"),
    t("table.header.who"),
    t("table.header.memberRole"),
    t("table.header.stage"),
    t("table.header.effortValue"),
    t("table.header.effortMoney"),
    t("table.header.startTimeToComputation"),
    t("table.header.finishTimeToComputation"),
    t("table.header.stagePercentage"),
    t("table.header.pairingPercentage"),
    t("table.header.managementPercentage"),
    t("table.header.totalBlocked"),
    t("table.header.mainEffortInTransition"),
    t("table.header.automaticUpdate"),
    "",
  ]
  const tableRows =
    demand?.demandEfforts?.map((effort) => [
      effort.id,
      effort.who || "",
      effort.memberRole || "",
      effort.stage || "",
      effort.effortValue ? Number(effort.effortValue).toFixed(2) : 0,
      effort.effortMoney ? Number(effort.effortMoney).toFixed(2) : 0,
      effort.startTimeToComputation ? (
        <DateLocale time date={effort.startTimeToComputation} />
      ) : (
        ""
      ),
      effort.finishTimeToComputation ? (
        <DateLocale time date={effort.finishTimeToComputation} />
      ) : (
        ""
      ),
      (Number(effort.stagePercentage || 0) * 100).toFixed(2) || 0,
      (Number(effort.pairingPercentage || 0) * 100).toFixed(2) || 0,
      (Number(effort.managementPercentage || 0) * 100).toFixed(2) || 0,
      effort.totalBlocked || 0,
      effort.mainEffortInTransition ? <CheckIcon color="primary" /> : "",
      effort.automaticUpdate ? <CheckIcon color="primary" /> : "",
      <Link
        href={`/companies/${params.company}/demands/${params.demand}/demand_efforts/${effort.id}/edit`}
      >
        <EditIcon />
      </Link>,
    ]) || []

  return demand ? (
    <DemandBasicPage demand={demand} loading={loading}>
      <Table headerCells={tableHeader} rows={tableRows} />
    </DemandBasicPage>
  ) : null
}

export default DemandEfforts

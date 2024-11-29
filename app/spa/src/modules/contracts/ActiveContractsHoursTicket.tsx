import { Box } from "@mui/material"
import { useTranslation } from "react-i18next"
import { Project } from "../project/project.types"
import TicketGroup from "../../components/TicketGroup"

type ActiveContractsHoursTicketProps = {
  project: Project
}

const ActiveContractsHoursTicket = ({
  project,
}: ActiveContractsHoursTicketProps) => {
  const { t } = useTranslation(["statusReport"])

  const activeContractHours = [
    {
      title: t("contract.total"),
      value: project?.totalActiveContractsHours?.toLocaleString("pt-BR", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }),
      unity: "h",
    },
    {
      title: t("contract.consumed"),
      value: project?.consumedActiveContractsHours?.toLocaleString("pt-BR", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }),
      unity: "h",
    },
    {
      title: t("contract.remaining"),
      value: project?.remainingActiveContractsHours?.toLocaleString("pt-BR", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }),
      unity: "h",
    },
  ]

  return (
    <Box
      sx={{
        backgroundColor: "white",
        padding: 4,
        width: "50%",
        borderRadius: 2,
      }}
    >
      <TicketGroup
        title={t("contract.title")}
        data={activeContractHours}
        spaced={false}
      />
    </Box>
  )
}

export default ActiveContractsHoursTicket

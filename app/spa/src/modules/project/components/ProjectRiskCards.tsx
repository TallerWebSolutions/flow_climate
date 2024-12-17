import Card, { CardType } from "../../../components/Card"
import { Box } from "@mui/material"
import { useTranslation } from "react-i18next"

const ProjectRiskCards = ({
  remainingDays,
  currentOperationalRisk,
  currentTeamRisk,
}: ProjectRiskCardsProps) => {
  const { t } = useTranslation(["generalProjectPage"])

  const currentRiskToDeadlinePercentage = (
    currentOperationalRisk * 100
  ).toFixed(2)
  const currentTeamRiskPercentage = (currentTeamRisk * 100).toFixed(2)
  const cardTypeTeamRisk = cardTypeByRisk(currentTeamRisk)
  const cardTypeOperationalRisk = cardTypeByRisk(currentOperationalRisk)

  return (
    <Box sx={{ display: "flex", my: 2 }}>
      <Card
        style={{ width: "350px", marginRight: "20px" }}
        title={t("cards.operational_risk")}
        subtitle={t("cards.operational_risk_message", {
          days: remainingDays,
          percentage: currentRiskToDeadlinePercentage,
        })}
        type={cardTypeOperationalRisk}
      />

      <Card
        style={{ width: "350px" }}
        title={t("cards.operational_risk_team_data")}
        subtitle={t("cards.operational_risk_team_data_message", {
          risk: currentTeamRiskPercentage,
        })}
        type={cardTypeTeamRisk}
      />
    </Box>
  )
}

type ProjectRiskCardsProps = {
  remainingDays: number
  currentOperationalRisk: number
  currentTeamRisk: number
}

const cardTypeByRisk = (risk: number) => {
  if (risk > 0.5 && risk <= 0.7) {
    return CardType.WARNING
  } else if (risk > 0.7) {
    return CardType.ERROR
  }

  return CardType.SUCCESS
}

export default ProjectRiskCards

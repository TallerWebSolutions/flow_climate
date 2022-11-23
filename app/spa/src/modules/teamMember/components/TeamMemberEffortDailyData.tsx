import { useTranslation } from "react-i18next"
import { axisDataToKeyValue } from "../../../lib/charts"
import { ChartGridItem } from "../../../components/charts/ChartGridItem"
import { BarChart } from "../../../components/charts/BarChart"
import { TeamMember } from "../teamMember.types"

type TeamMemberEffortDailyDataProps = {
  teamMember: TeamMember
}

const TeamMemberEffortDailyData = ({
  teamMember,
}: TeamMemberEffortDailyDataProps) => {
  const { t } = useTranslation(["teamMembers"])

  const memberEffortDailyData = {
    ...teamMember.memberEffortDailyData,
    xAxis: teamMember.memberEffortDailyData?.xAxis || [],
    yAxis: teamMember.memberEffortDailyData?.yAxis || [],
  }

  return (
    <>
      {memberEffortDailyData && (
        <ChartGridItem title={t("charts.memberEffortDaily")}>
          <BarChart
            data={axisDataToKeyValue(memberEffortDailyData)}
            keys={["value"]}
            indexBy="key"
          />
        </ChartGridItem>
      )}
    </>
  )
}

export default TeamMemberEffortDailyData

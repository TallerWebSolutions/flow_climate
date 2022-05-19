import { Grid } from "@mui/material"

import { TeamMember } from "../modules/teamMember/teamMember.types"
import { BarChart } from "./charts/BarChart"
import { ScatterChart } from "./charts/ScatterChart"

type TeamMemberDashboardChartsProps = {
  teamMember: TeamMember
}

const TeamMemberDashboardCharts = ({
  teamMember,
}: TeamMemberDashboardChartsProps) => {
  const leadTimeHistogramChartData = teamMember.leadTimeHistogramChartData
  const leadTimeControlChartData = teamMember.leadTimeControlChartData

  return (
    <Grid container spacing={2}>
      {leadTimeHistogramChartData && (
        <Grid item xs={6}>
          <BarChart
            indexBy="key"
            data={leadTimeHistogramChartData}
            keys={["value"]}
            padding={0}
          />
        </Grid>
      )}
      {leadTimeControlChartData && (
        <Grid item xs={6}>
          <ScatterChart data={leadTimeControlChartData} />
        </Grid>
      )}
    </Grid>
  )
}

export default TeamMemberDashboardCharts

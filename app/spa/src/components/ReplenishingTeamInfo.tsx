import { Divider, Grid, Typography } from "@mui/material"
import { Box } from "@mui/system"
import { Fragment } from "react"
import { Project } from "../modules/project/project.types"
import Card, { CardType } from "./Card"

type ComparativeValue = {
  value: number
  increased: boolean
}

export type TeamReplenishment = {
  throughputData?: number[]
  averageThroughput?: ComparativeValue
  leadTime?: ComparativeValue
  workInProgress?: number
  projects: Project[]
}

type ReplenishmentTeamInfoProps = {
  team: TeamReplenishment
}

export const getWipLimits = (projects: Project[]): number[] =>
  projects.map(({ maxWorkInProgress }) => maxWorkInProgress || 0)

export const isTeamWipLimitSurpassed = (
  projects: Project[],
  teamWipLimit?: number
) => getWipLimits(projects).reduce((a, b) => a + b, 0) > Number(teamWipLimit)

const ReplenishmentTeamInfo = ({ team }: ReplenishmentTeamInfoProps) => (
  <Grid container spacing={15} mb={4} sx={{ pointerEvents: "none" }}>
    <Grid item xs={4}>
      <Card
        title="Throughput"
        subtitle="Últimas quatro semanas"
        type={CardType.PRIMARY}
      >
        <Box display="flex">
          {team.throughputData?.map((th, index, list) => (
            <Fragment key={`${th}--${index}`}>
              <Typography key={`value--${index}`}>{th}</Typography>
              {index < list.length - 1 && (
                <Divider
                  key={`divider--${index}`}
                  variant="middle"
                  orientation="vertical"
                  flexItem
                  sx={{ marginX: 2 }}
                />
              )}
            </Fragment>
          ))}
        </Box>
      </Card>
    </Grid>
    <Grid item xs={4}>
      <Card
        title="Lead Time"
        subtitle="Últimas quatro semanas"
        type={CardType.PRIMARY}
      >
        <Typography>{team.leadTime?.value?.toFixed(2)}</Typography>
      </Card>
    </Grid>
    <Grid item xs={4}>
      <Card
        title="Work in Progress"
        subtitle="WiP máximo do time"
        type={
          isTeamWipLimitSurpassed(team.projects, team.workInProgress)
            ? CardType.WARNING
            : CardType.PRIMARY
        }
      >
        <Typography>{team.workInProgress}</Typography>
      </Card>
    </Grid>
  </Grid>
)

export default ReplenishmentTeamInfo

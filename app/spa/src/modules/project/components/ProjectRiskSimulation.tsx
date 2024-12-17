import { Project } from "../project.types"
import {
  Box,
  Button,
  FormGroup,
  Grid,
  Input,
  InputLabel,
  Typography,
} from "@mui/material"
import { FormElement } from "../../../components/ui/Form"
import { FieldValues, useForm } from "react-hook-form"
import { gql, useLazyQuery } from "@apollo/client"
import ProjectMonteCarloData from "./ProjectMonteCarloData"
import ProjectMonteCarloTeamData from "./ProjectMonteCarloTeamData"
import ProjectRiskCards from "./ProjectRiskCards"
import { differenceInDays, parseISO } from "date-fns"

const ProjectRiskSimulation = ({ project }: ProjectRiskSimulationProps) => {
  const { register, handleSubmit } = useForm()

  const [simulateProjectRisk, { data, variables }] =
    useLazyQuery<ProjectSimulationDTO>(PROJECT_SIMULATION_QUERY)

  const onSubmit = (values: FieldValues) => {
    simulateProjectRisk({
      variables: {
        projectId: project.id,
        remainingWork: Number(values.remainingWork || 0),
        throughputs: values.throughputs.split(",").map(Number),
        endDate: values.endDate,
      },
    })
  }

  const projectSimulation = data?.project?.projectSimulation
  const remainingDays = differenceInDays(
    parseISO(variables?.endDate),
    new Date()
  )

  return (
    <Box marginY={4}>
      <Typography variant="h4" component="h2" lineHeight={2}>
        Simulação de risco
      </Typography>
      <form onSubmit={handleSubmit(onSubmit)}>
        <FormGroup>
          <Grid container spacing={5}>
            <FormElement>
              <InputLabel htmlFor="endDate" shrink>
                End Date
              </InputLabel>
              <Input
                type="date"
                {...register("endDate")}
                defaultValue={project.endDate}
              />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="remainingWork">End Date</InputLabel>
              <Input
                type="number"
                {...register("remainingWork")}
                defaultValue={project.remainingWork}
              />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="throughputs">End Date</InputLabel>
              <Input
                {...register("throughputs")}
                defaultValue={project.weeklyThroughputs?.join(",")}
              />
            </FormElement>
            <FormElement>
              <Button sx={{ alignSelf: "flex-start" }} type="submit">
                Simular
              </Button>
            </FormElement>
          </Grid>
        </FormGroup>
      </form>

      {projectSimulation && project && (
        <>
          <ProjectRiskCards
            remainingDays={remainingDays}
            currentOperationalRisk={projectSimulation.operationalRisk || 0}
            currentTeamRisk={projectSimulation.teamOperationalRisk || 0}
          />

          <ProjectMonteCarloData
            currentMonteCarloWeeksMin={
              projectSimulation.currentMonteCarloWeeksMin || 0
            }
            currentMonteCarloWeeksMax={
              projectSimulation.currentMonteCarloWeeksMax || 0
            }
            monteCarloP80={projectSimulation.monteCarloP80 || 0}
            currentMonteCarloWeeksStdDev={
              projectSimulation.currentMonteCarloWeeksStdDev || 0
            }
          />

          <ProjectMonteCarloTeamData
            teamMonteCarloWeeksMin={
              projectSimulation.teamMonteCarloWeeksMin || 0
            }
            teamMonteCarloWeeksMax={
              projectSimulation.teamMonteCarloWeeksMax || 0
            }
            teamMonteCarloP80={projectSimulation.teamMonteCarloP80 || 0}
            teamMonteCarloWeeksStdDev={
              projectSimulation.teamMonteCarloWeeksStdDev || 0
            }
          />
        </>
      )}
    </Box>
  )
}

type ProjectRiskSimulationProps = {
  project: Project
}

const PROJECT_SIMULATION_QUERY = gql`
  query ProjectSimulation(
    $projectId: ID!
    $remainingWork: Int!
    $throughputs: [Int!]!
    $endDate: ISO8601Date!
  ) {
    project(id: $projectId) {
      id
      projectSimulation(
        remainingWork: $remainingWork
        throughputs: $throughputs
        endDate: $endDate
      ) {
        operationalRisk
        teamOperationalRisk

        currentMonteCarloWeeksMin
        currentMonteCarloWeeksMax
        monteCarloP80
        currentMonteCarloWeeksStdDev

        teamMonteCarloWeeksMin
        teamMonteCarloWeeksMax
        teamMonteCarloP80
        teamMonteCarloWeeksStdDev
      }
    }
  }
`

type ProjectSimulationDTO = {
  project?: Project
}

export default ProjectRiskSimulation

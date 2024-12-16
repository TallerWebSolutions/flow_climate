import { Project } from "../project.types"
import { Button, FormGroup, Input, InputLabel } from "@mui/material"
import { FormElement } from "../../../components/ui/Form"
import { FieldValues, useForm } from "react-hook-form"
import { gql, useLazyQuery } from "@apollo/client"
import ProjectMonteCarloData from "./ProjectMonteCarloData"
import ProjectMonteCarloTeamData from "./ProjectMonteCarloTeamData"

const ProjectRiskSimulation = ({ project }: ProjectRiskSimulationProps) => {
  const { register, handleSubmit } = useForm()

  const [simulateProjectRisk, { data }] = useLazyQuery<ProjectSimulationDTO>(
    PROJECT_SIMULATION_QUERY
  )

  const onSubmit = (values: FieldValues) => {
    simulateProjectRisk({
      variables: {
        projectId: project.id,
        remainingWork: Number(values.remainingWork || 0),
        throughputs: values.throughputs.split(",").map(Number),
      },
    })
  }

  const projectSimulation = data?.project?.projectSimulation

  return (
    <>
      <form onSubmit={handleSubmit(onSubmit)}>
        <FormGroup>
          <FormElement>
            <InputLabel htmlFor="endDate">End Date</InputLabel>
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
        </FormGroup>
      </form>

      {projectSimulation && project && (
        <>
          <ProjectMonteCarloData project={project} />
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
    </>
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
  ) {
    project(id: $projectId) {
      id
      projectSimulation(
        remainingWork: $remainingWork
        throughputs: $throughputs
      ) {
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

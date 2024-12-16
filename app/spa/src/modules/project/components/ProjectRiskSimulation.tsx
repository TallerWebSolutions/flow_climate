import { Project } from "../project.types"
import { Button, FormGroup, Input, InputLabel } from "@mui/material"
import { FormElement } from "../../../components/ui/Form"
import { useForm } from "react-hook-form"
import { useTranslation } from "react-i18next"

const ProjectRiskSimulation = ({ project }: ProjectRiskSimulationProps) => {
  const { t } = useTranslation("demand")
  const { register, handleSubmit } = useForm()

  const simulateProjectRisk = () => {
    alert("simulou")
  }

  return (
    <form onSubmit={handleSubmit(simulateProjectRisk)}>
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
          <Button sx={{ alignSelf: "flex-start" }} type="submit">
            Simular
          </Button>
        </FormElement>
      </FormGroup>
    </form>
  )
}

type ProjectRiskSimulationProps = {
  project: Project
}

export default ProjectRiskSimulation

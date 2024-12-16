import TicketGroup from "../../../components/TicketGroup"
import { Project } from "../project.types"

const ProjectMonteCarloData = ({ project }: ProjectMonteCarloDataProps) => {
  const monteCarloProject = [
    {
      title: "Mínimo",
      value: project?.currentMonteCarloWeeksMin,
      unity: "semanas",
    },
    {
      title: "Máximo",
      value: project?.currentMonteCarloWeeksMax,
      unity: "semanas",
    },
    {
      title: "Percentil 80",
      value: project?.monteCarloP80?.toFixed(2),
      unity: "semanas",
    },
    {
      title: "Desvio padrão",
      value: project?.currentMonteCarloWeeksStdDev?.toFixed(2),
      unity: "semanas",
    },
  ]

  return <TicketGroup title="Monte Carlo (Projeto)" data={monteCarloProject} />
}

type ProjectMonteCarloDataProps = {
  project: Project
}

export default ProjectMonteCarloData

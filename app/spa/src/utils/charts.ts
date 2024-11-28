import { Burnup } from "../modules/project/project.types"

export const buildBurnupData = (
  scopeLabel: string,
  idealLabel: string,
  deliveredLabel: string,
  data?: Burnup
) => [
  {
    id: scopeLabel,
    data:
      data?.scope.map((scope, index) => ({
        x: data.xAxis?.[index],
        y: scope,
      })) || [],
  },
  {
    id: idealLabel,
    data:
      data?.idealBurn.map((idealScope, index) => ({
        x: data.xAxis?.[index],
        y: idealScope.toFixed(2),
      })) || [],
  },
  {
    id: deliveredLabel,
    data:
      data?.currentBurn.map((projectThroughput, index) => ({
        x: data.xAxis?.[index],
        y: projectThroughput,
      })) || [],
  },
]

import { BarDatum } from "@nivo/bar"
import { ScatterPlotDatum, ScatterPlotRawSerie } from "@nivo/scatterplot"

import { KeyValueData, ChartAxisData } from "../modules/project/project.types"

export const keyValueToHistogramData = (data: KeyValueData): BarDatum[] =>
  data.keys.map((key, index) => {
    return { value: data.values[index], key }
  })

export const axisDataToScatter = (
  data: ChartAxisData
): ScatterPlotRawSerie<ScatterPlotDatum>[] => [
  {
    id: "truco",
    data: data.yAxis.map((y, index) => ({
      x: index,
      y,
    })),
  },
]

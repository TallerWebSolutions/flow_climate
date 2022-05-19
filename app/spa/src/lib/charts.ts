import { BarDatum } from "@nivo/bar"
import { ScatterPlotDatum, ScatterPlotRawSerie } from "@nivo/scatterplot"

import { KeyValueData, ChartAxisData } from "../modules/project/project.types"

export const keyValueToHistogramData = (data: KeyValueData): BarDatum[] =>
  data.keys.map((key, index) => {
    return { value: data.values[index], key }
  })

export const axisDataToScatter = (
  data: ChartAxisData,
  pointLegend: string
): ScatterPlotRawSerie<ScatterPlotDatum>[] => [
  {
    id: pointLegend,
    data: data.yAxis.map((y, index) => ({
      x: index,
      y,
    })),
  },
]

export const axisDataToKeyValue = (data: ChartAxisData): KeyValueData => ({
  keys: data.xAxis,
  values: data.yAxis,
})

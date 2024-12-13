import { BarDatum } from "@nivo/bar"
import { ScatterPlotDatum, ScatterPlotRawSerie } from "@nivo/scatterplot"
import {
  ChartAxisData,
  KeyValueData,
  SimpleListChartData,
} from "../modules/charts/charts.types"

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
    data:
      data.yAxis?.map((y, index) => ({
        x: index,
        y,
      })) || [],
  },
]

export const axisDataToKeyValue = (data: ChartAxisData): KeyValueData => ({
  keys: data.xAxis || [],
  values: data.yAxis || [],
})

export const keyValueToAxisData = (data: KeyValueData): ChartAxisData => ({
  yAxis: data.keys,
  xAxis: data.values.map(String),
})

export const cfdChartData = (
  stages: string[],
  xAxis: string[],
  yAxis: SimpleListChartData[]
) =>
  stages.map((stage, stageIndex) => ({
    id: stage,
    data: xAxis.map((x, index) => ({
      x,
      y: yAxis[stageIndex].data[index] || 0,
    })),
  }))

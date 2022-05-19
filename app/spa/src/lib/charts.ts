import { BarDatum } from "@nivo/bar"
import { KeyValueData } from "../modules/project/project.types"

export const keyValueToHistogramData = (data: KeyValueData): BarDatum[] =>
  data.keys.map((key, index) => {
    return { value: data.values[index], key }
  })

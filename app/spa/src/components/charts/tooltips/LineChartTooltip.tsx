import { DatumValue } from "@nivo/core"
import { Point } from "@nivo/line"

type Slice = {
  id: DatumValue
  height: number
  width: number
  x0: number
  x: number | string | Date
  y0: number
  y: number
  points: readonly Point[]
}

type ChartTooltipProps = {
  xLabel?: string
  slice: Slice
}

const LineChartTooltip = ({ slice, xLabel }: ChartTooltipProps) => {
  const xValue = slice.points[0].data.xFormatted

  return (
    <div
      style={{
        background: "white",
        padding: "6px 8px",
        border: "1px solid #ccc",
      }}
    >
      {xLabel && (
        <p style={{ fontSize: 14, margin: 0, padding: 0 }}>
          {xLabel}: {xValue}
        </p>
      )}
      {slice.points.map((point) => (
        <div
          key={point.id}
          style={{
            color: point.serieColor,
            padding: "3px 0",
          }}
        >
          <p
            style={{
              fontSize: 14,
              margin: 0,
              padding: 0,
              fontWeight: "bold",
            }}
          >
            {point.serieId}: {point.data.yFormatted}
          </p>
        </div>
      ))}
    </div>
  )
}

export default LineChartTooltip

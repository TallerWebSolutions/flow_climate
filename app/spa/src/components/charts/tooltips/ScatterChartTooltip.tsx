type AxisValue = number | String | Date

export type ScatterNode = {
  index: number
  serieIndex: number
  serieId: string
  x: AxisValue
  xValue: AxisValue
  formattedX: string
  y: AxisValue
  yValue: AxisValue
  formattedY: string
  data: ChartData
  id: string
  size: number
  color: string
}

type ChartData = {
  x: number | String | Date
  y: number | String | Date
}

type ChartTooltipProps = {
  xLabel: string
  node: ScatterNode
}

const ScatterChartTooltip = ({ node, xLabel }: ChartTooltipProps) => {
  const xValue = node.formattedX

  return (
    <div
      style={{
        background: "white",
        padding: "6px 8px",
        border: "1px solid #ccc",
      }}
    >
      <p style={{ fontSize: 14, margin: 0, padding: 0 }}>
        {xLabel}: {xValue}
      </p>

      <div
        style={{
          color: node.color,
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
          {node.serieId}: {node.formattedY}
        </p>
      </div>
    </div>
  )
}

export default ScatterChartTooltip

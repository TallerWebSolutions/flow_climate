export type BarData = {
  index: number
  x: number
  y: number
  absX: number
  absY: number
  width: number
  height: number
  color: string
  label: string
  id: string
  value: number
  formattedValue: string
  hidden: boolean
  indexValue: string
}

type ChartTooltipProps = {
  xLabel: string
  data: BarData
}

const BarChartTooltip = ({ data, xLabel }: ChartTooltipProps) => {
  const xValue = data.indexValue

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
          color: data.color,
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
          {data.id}: {data.formattedValue}
        </p>
      </div>
    </div>
  )
}

export default BarChartTooltip

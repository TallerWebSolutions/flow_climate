const format = ({
  offsetDays = 0,
}: {
  offsetDays?: number
} = {}) => {
  const date = new Date()
  date.setDate(date.getDate() + offsetDays)

  const month = date.getMonth() + 1
  const year = date.getFullYear()

  const formattedMonth = month < 10 ? "0" + month : month
  const formattedDate =
    date.getDate() < 10 ? "0" + date.getDate() : date.getDate()

  return `${year}-${formattedMonth}-${formattedDate}`
}

export const formattedRelativeDate = {
  format,
}

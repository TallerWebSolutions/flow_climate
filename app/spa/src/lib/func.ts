export const formatLeadtime = (leadtime: number): number =>
  Number((leadtime / 86400).toFixed(2))

export const capitalizeFirstLetter = (string: string): string => {
  return string.charAt(0).toUpperCase() + string.slice(1)
}

export const redirectTo = (link: string): void => {
  window.location.assign(link)
}

export const openWindow = (link: string): void => {
  window.open(link, "_blank")
}

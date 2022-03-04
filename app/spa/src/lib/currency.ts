import currency from "currency.js"

export const formatCurrency = (amount: number) =>
  currency(amount, {
    symbol: "R$ ",
    precision: 2,
    separator: ".",
    decimal: ",",
  }).format()

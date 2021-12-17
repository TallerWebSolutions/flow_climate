import { ReactElement } from "react"
import {
  createTheme,
  ThemeProvider as MaterialThemeProvider,
} from "@mui/material/styles"

const theme = createTheme({
  palette: {
    secondary: {
      light: "#634C6B",
      main: "#29172E",
      dark: "#140318",
    },
  },
})

const ThemeProvider = ({ children }: { children: ReactElement }) => (
  <MaterialThemeProvider theme={theme}>{children}</MaterialThemeProvider>
)

export default ThemeProvider

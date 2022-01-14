import { ReactElement } from "react"
import {
  createTheme,
  ThemeProvider as MaterialThemeProvider,
} from "@mui/material/styles"

const theme = createTheme({
  palette: {
    primary: {
      light: "#523E57",
      main: "#29172E",
      dark: "#000004",
    },
    secondary: {
      light: "#634C6B",
      main: "#29172E",
      dark: "#140318",
    },
  },
  components: {
    MuiTableCell: {
      styleOverrides: {
        root: {
          borderBottom: "none",
        },
      },
    },
  },
})

const ThemeProvider = ({ children }: { children: ReactElement }) => (
  <MaterialThemeProvider theme={theme}>{children}</MaterialThemeProvider>
)

export default ThemeProvider

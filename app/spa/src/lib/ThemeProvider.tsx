import { ReactElement } from "react"
import {
  createTheme,
  ThemeProvider as MaterialThemeProvider,
} from "@mui/material/styles"

const theme = createTheme({
  palette: {
    primary: {
      light: "#9674A2",
      main: "#523E57",
      dark: "#29172E",
    },
    secondary: {
      light: "#634C6B",
      main: "#29172E",
      dark: "#140318",
    },
  },
  typography: {
    body1: {
      fontFamily: "'Roboto', 'Helvetica', 'Arial', sans-serif",
      fontWeight: 400,
      fontSize: "1rem",
      lineHeight: 1.5,
    },
    body2: {
      fontFamily: "'Roboto', 'Helvetica', 'Arial', sans-serif",
      fontWeight: 400,
      fontSize: ".875rem",
      lineHeight: 1.43,
    },
    subtitle1: {
      fontFamily: "'Roboto', 'Helvetica', 'Arial', sans-serif",
      fontWeight: 500,
      fontSize: "1rem",
      lineHeight: 1.75,
      color: "black",
    },
    subtitle2: {
      fontFamily: "'Roboto', 'Helvetica', 'Arial', sans-serif",
      fontWeight: 500,
      fontSize: ".875rem",
      lineHeight: 1.57,
      color: "black",
    },
  },
  components: {
    MuiTableCell: {
      styleOverrides: {
        root: {
          borderBottom: "none",
          padding: "8px",
        },
      },
    },
    MuiLink: {
      defaultProps: {
        variant: "body2",
      },
    },
    MuiCard: {
      defaultProps: {
        variant: "outlined",
      },
      styleOverrides: {
        root: {
          borderRadius: 2,
        },
      },
    },
  },
})

const ThemeProvider = ({ children }: { children: ReactElement }) => (
  <MaterialThemeProvider theme={theme}>{children}</MaterialThemeProvider>
)

export default ThemeProvider

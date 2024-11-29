import CheckCircleIcon from "@mui/icons-material/CheckCircle"
import ErrorIcon from "@mui/icons-material/Error"
import WarningIcon from "@mui/icons-material/Warning"
import {
  Box,
  Card as MUICard,
  CardContent,
  CardContentProps,
  CardProps,
  Typography,
} from "@mui/material"

export enum CardType {
  PRIMARY = "primary",
  WARNING = "warning",
  SUCCESS = "success",
  ERROR = "error",
}

type CustomCardProps = {
  subtitle: string
  title: string
  type: CardType
} & CardProps

type CustomCardContentProps = {
  title: string
  subtitle: string
  type: CardType
} & CardContentProps

const CustomCardContent = ({
  children,
  title,
  subtitle,
  type,
  ...props
}: CustomCardContentProps) => (
  <CardContent {...props} sx={{ ":last-child": { paddingBottom: 2 } }}>
    <Box sx={{ display: "flex", alignItems: "center" }}>
      {type === CardType.ERROR && <ErrorIcon color={type} sx={{ mr: 1 }} />}
      {type === CardType.WARNING && <WarningIcon color={type} sx={{ mr: 1 }} />}
      {type === CardType.SUCCESS && (
        <CheckCircleIcon color={type} sx={{ mr: 1 }} />
      )}
      <Typography
        variant="h6"
        component="h6"
        style={{ lineHeight: 1.2, marginBottom: "10px" }}
      >
        {title}
      </Typography>
    </Box>

    <Typography
      variant="body2"
      component="span"
      color="grwy.600"
      mb={1}
      display="block"
    >
      {subtitle}
    </Typography>
    {children}
  </CardContent>
)

const Card = ({
  children,
  title,
  subtitle,
  type,
  ...props
}: CustomCardProps) => (
  <MUICard
    {...props}
    sx={{
      borderColor: type === CardType.PRIMARY ? "#ccc" : `${type}.light`,
    }}
  >
    <CustomCardContent title={title} subtitle={subtitle} type={type}>
      {children}
    </CustomCardContent>
  </MUICard>
)

export default Card

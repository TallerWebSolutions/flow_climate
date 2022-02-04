import {
  Card as MUICard,
  CardProps,
  CardContent,
  CardContentProps,
  Typography,
} from "@mui/material"
import ErrorIcon from "@mui/icons-material/Error"

type CustomCardContentProps = {
  title: string
  subtitle: string
} & CardContentProps

const CustomCardContent = ({
  children,
  title,
  subtitle,
  ...props
}: CustomCardContentProps) => (
  <CardContent {...props} sx={{ ":last-child": { paddingBottom: 2 } }}>
    <Typography variant="h6" component="h6">
      {title}
    </Typography>
    <Typography
      variant="body2"
      component="span"
      color="grey.600"
      mb={1}
      display="block"
    >
      {subtitle}
    </Typography>
    {children}
  </CardContent>
)

export enum CardType {
  primary,
  alert,
}

type CustomCardProps = {
  subtitle: string
  title: string
  type?: CardType
} & CardProps

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
      borderColor: type === CardType.alert ? "warning.light" : "#ccc",
    }}
  >
    {type === CardType.alert && (
      <ErrorIcon color="warning" sx={{ float: "right", margin: 2 }} />
    )}
    <CustomCardContent title={title} subtitle={subtitle}>
      {children}
    </CustomCardContent>
  </MUICard>
)

export default Card

import {
  Card as MUICard,
  CardProps,
  CardContent,
  CardContentProps,
  Typography,
} from "@mui/material"
import ErrorIcon from "@mui/icons-material/Error"
import CheckCircleIcon from "@mui/icons-material/CheckCircle"

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
  PRIMARY = "primary",
  WARNING = "warning",
  SUCCESS = "success",
}

type CustomCardProps = {
  subtitle: string
  title: string
  type: CardType
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
      borderColor: type === CardType.PRIMARY ? "#ccc" : `${type}.light`,
    }}
  >
    {type === CardType.WARNING && (
      <ErrorIcon color={type} sx={{ float: "right", margin: 2 }} />
    )}
    {type === CardType.SUCCESS && (
      <CheckCircleIcon color={type} sx={{ float: "right", margin: 2 }} />
    )}
    <CustomCardContent title={title} subtitle={subtitle}>
      {children}
    </CustomCardContent>
  </MUICard>
)

export default Card

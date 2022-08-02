import { Company } from "../company/company.types"

type Avatar = {
  imageSource: string
}

type User = {
  id?: string
  language?: string
  currentCompany?: Company
  fullName?: string
  firstName?: string
  lastName?: string
  avatar?: Avatar
  companies?: Company[]
  admin?: boolean
}

export default User

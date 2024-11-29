import { Company } from "../company/company.types"
import { Product } from "../product/product.types"
import { Project } from "../project/project.types"

type Avatar = {
  imageSource: string
}

export type User = {
  id: string
  language?: string
  currentCompany?: Company
  fullName?: string
  firstName?: string
  lastName?: string
  avatar?: Avatar
  companies?: Company[]
  products?: Product[]
  projects?: Project[]
  projectsActive?: Project[]
  admin?: boolean
  userIsManager?: boolean
}

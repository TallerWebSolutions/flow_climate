import { Company } from "../company/company.types"
import { Product } from "../product/product.types"

type JiraProductConfig = {
  id?: string
  company?: Company
  product?: Product
  jiraProductKey?: string
  
}

export type JiraProjectConfig = {
  id?: string
  jiraProductConfig?: JiraProductConfig
  fixVersionName?: string
}
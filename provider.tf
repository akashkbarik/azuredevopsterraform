terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.108.0"
    }
  }
}
provider "azurerm" {
  features {}
  skip_provider_registration = true
  client_id                  = "fdcfd5ec-5105-4c25-a554-d4a25e29558b"
  client_secret              = "rnx8Q~Kvu84cNOtFis1ocGf_prHG47jM-TwZ2bPr"
  tenant_id                  = "825427c7-de8c-469e-be61-254a4e48442e"
  subscription_id            = "a25d286e-68a4-4c24-8d88-d34e1a49ee20"

}
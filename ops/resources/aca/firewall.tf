resource "azurerm_web_application_firewall_policy" "aca_waf_policy" {
  name                = "${local.name}-wafpolicy"
  resource_group_name = var.resource_group_name
  location            = var.location

  custom_rules {
    name      = "Block_Sanctioned_Entities"
    priority  = 1
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }
      operator           = "GeoMatch"
      negation_condition = false
      match_values = [
        "AF", //Afghanistan (ITAR)
        "AL", //Albania (OFAC)
        "BA", //Bosnia and Herzegovinia (OFAC)
        "BG", //Bulgaria (OFAC)
        "BY", //Belarus (ITAR, OFAC)
        "CD", //Democratic Republic of the Congo (ITAR)
        "CF", //Central African Republic (ITAR, OFAC)
        "CG", //Congo (ITAR, OFAC)
        "CI", //Côte d'Ivoire (ITAR)
        "CN", //People's Republic of China (EAR, ITAR)
        "CU", //Cuba (EAR, ITAR, OFAC)
        "CY", //Cyprus (ITAR)
        "ER", //Eritrea (ITAR)
        "ET", //Ethiopia (ITAR-adjacent, due to ongoing conflict with Eritrea)
        "GE", //Georgia (preemptive, due to presence of separatist regions sympathetic to Russian Federation)
        "HK", //Hong Kong SAR (due to oversight by People's Republic of China)
        "HR", //Croatia (OFAC)
        "HT", //Haiti (ITAR)
        "IQ", //Iraq (EAR, ITAR, OFAC)
        "IR", //Iran, Islamic Republic of (EAR, ITAR, OFAC)
        "KP", //Korea, Democratic People's Republic of (EAR, ITAR, OFAC)
        "LB", //Lebanon (ITAR, OFAC)
        "LK", //Sri Lanka (ITAR)
        "LR", //Liberia (ITAR, OFAC)
        "LY", //Libya (ITAR, OFAC)
        "MD", //Moldova, Republic of (preemptive, due to presence of separatist regions sympathetic to Russian Federation)
        "ME", //Montenegro (OFAC)
        "MK", //North Macedonia (OFAC)
        "MM", //Myanmar (ITAR)
        "MO", //Macao SAR (due to oversight by People's Republic of China)
        "NI", //Nicaragua (preemptive, due to association with sanctioned entities)
        "RS", //Serbia (OFAC)
        "RU", //Russian Federation (EAR, OFAC)
        "SO", //Somalia (ITAR, OFAC)
        "SY", //Syrian Arab Republic (EAR, ITAR, OFAC)
        "UA", //Ukraine (OFAC, due to occupation by the Russian Federation)
        "VE", //Venezuela (EAR, ITAR, OFAC)
        "VN", //Vietnam (ITAR)
        "XK", //Kosovo (OFAC)
        "YE", //Yemen (OFAC)
        "ZW"  //Zimbabwe (ITAR)
      ]
    }
    action = "Block"
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = "Detection" //Can use "Detection" for testing, to see which requests would be blocked. "Prevention" turns on active blocking.
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 1024 //Can go to 2000 in modern provider version. Proposed is 1024.
  }
}
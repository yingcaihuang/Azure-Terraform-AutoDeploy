variable "profile_id" {
  type = string
}

variable "rule_set_name" {
  type = string
}

variable "enable_jpg" {
  type    = bool
  default = true
}

variable "jpg_rule_name" {
  type    = string
  default = "jpgcache30d"
}

variable "jpg_rule_order" {
  type    = number
  default = 1
}

variable "jpg_cache_seconds" {
  type    = number
  default = 2592000
}

variable "jpg_match_values" {
  type    = list(string)
  default = [".jpg", ".jpeg"]
}

variable "enable_css" {
  type    = bool
  default = true
}

variable "css_rule_name" {
  type    = string
  default = "csscache1d"
}

variable "css_rule_order" {
  type    = number
  default = 2
}

variable "css_cache_seconds" {
  type    = number
  default = 86400
}

variable "css_match_values" {
  type    = list(string)
  default = [".css"]
}

variable "enable_nocache" {
  type    = bool
  default = true
}

variable "nocache_rule_name" {
  type    = string
  default = "metonocache"
}

variable "nocache_rule_order" {
  type    = number
  default = 3
}

variable "nocache_match_values" {
  type    = list(string)
  default = ["/meto/"]
}

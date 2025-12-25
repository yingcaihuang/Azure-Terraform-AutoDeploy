variable "profile_id" { 
	type = string 
}

variable "origin_group_name" { 
	type = string 
}

variable "origin_name" { 
	type = string 
}

variable "origin_host_name" { 
	type = string 
}

variable "origin_host_header" { 
	type = string 
}

variable "origin_http_port" { 
	type    = number 
	default = 80 
}

variable "origin_https_port" { 
	type    = number 
	default = 443 
}

variable "name"               { 
    type = string 
}
variable "vpc_id"             { 
    type = string 
}
variable "private_subnet_ids" { 
    type = list(string) 
}
variable "public_subnet_ids"  { 
    type = list(string) 
}
variable "cluster_version"    { 
    type = string 
    default = "1.30" 
}
variable "desired_size"       { 
    type = number 
    default = 3 
}
variable "min_size"           { 
    type = number 
    default = 3 
}
variable "max_size"           { 
    type = number 
    default = 6 
}

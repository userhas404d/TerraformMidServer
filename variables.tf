variable "midserver_installer" {
  type = "string"
  description = "URL to Mid Server package."
  default = "https://install.service-now.com/glide/distribution/builds/package/mid/2018/02/26/mid.jakarta-05-03-2017__patch8-02-14-2018_02-26-2018_1106.linux.x86-64.zip"
}

# https://docs.servicenow.com/bundle/jakarta-servicenow-platform/page/product/mid-server/task/t_InstallAMIDServerOnLinux.html?cshalt=yes

variable "MidServerUrl" {
    type = "string"
    description = "URL to your target SN instance. Do not include https://"
}

variable "MidServerName" {
  type = "string"
  description = "MID Server name	Enter any MID Server name."
  default = "AWSMidServer"
}

variable "ServiceNowInstanceName" {
  type = "string"
  description = "Name of target ServiceNow instance"
}

variable "MidServerUser" {
  type = "string"
  description = "ServiceNow MID Server username. The MID Server user must have the mid_server role."
}

variable "MidServerUserPassword" {
  type = "string"
  description = "Enter the password for the user in the ServiceNow MID Server username."
}

variable "sn_user_name" {
  type = "string"
  description = "User name of the ServiceNow account making the REST api calls."
}
variable "sn_pwd" {
  type = "string"
  description = "Password of the ServiceNow account making the REST api calls."
}
variable "host_user" {
  type = "string"
  description = "User name of the host's user."
  default = "ec2-user"
}

variable "create_archive" {
  default = "false"
}

variable "reposync_repo" {
  default = "https://github.com/userhas404d/terrasnow.git"
}

variable "reposync_ref" {
  default = "Develop"
}

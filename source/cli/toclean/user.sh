#!/usr/bin/env sh

user::isroot()
{
  if [ $(id -u) != "0" ]; then
    ui::error "You must be root."
    exit 1
  fi
}

user:isnotroot()
{
  if [ $(id -u) = "0" ]; then
    ui::error "You are root. Downgrade to your administrative user account."
    exit 1
  fi
}

user::belongstogroup()
{
  if [ -z "$(groups | grep $1)" ]; then
    ui::error "You must belong to group $1"
    exit 1
  fi
}

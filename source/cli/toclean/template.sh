#!/usr/bin/env sh

template::process()
{
    local template="$(cat $1)"
    eval "echo \"${template}\""
}

template::execute()
{
    source "$1"
#    local template="$(cat $1)"
#    eval "\"${template}\""
}

template::confirm-before-execute()
{
  ui::info "Here is what we are going to do"
  ui::info "<---------------------->"
  template::process "$1"
  ui::info "<---------------------->"

  input::ask "Do you want to do that? Y/[n]" answer

  if [ "$answer" != "Y" ] && [ "$answer" != "y"  ]; then
    ui::warning "Cancelling and moving on"
  else
    template::execute "$1"
    ui::info "$2"
  fi
}

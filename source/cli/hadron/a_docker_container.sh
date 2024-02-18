#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

#Commands:
#  attach      Attach local standard input, output, and error streams to a running container
#  commit      Create a new image from a container's changes
#  cp          Copy files/folders between a container and the local filesystem
#  create      Create a new container
#  diff        Inspect changes to files or directories on a container's filesystem
#  exec        Execute a command in a running container
#  export      Export a container's filesystem as a tar archive
#  kill        Kill one or more running containers
#  logs        Fetch the logs of a container
#  pause       Pause all processes within one or more containers
#  port        List port mappings or a specific mapping for the container
#  prune       Remove all stopped containers
#  restart     Restart one or more containers
#  start       Start one or more stopped containers
#  stats       Display a live stream of container(s) resource usage statistics
#  top         Display the running processes of a container
#  unpause     Unpause all processes within one or more containers
#  update      Update configuration of one or more containers
#  wait        Block until one or more containers stop, then print their exit codes

# What we need
#  stop        Stop one or more running containers
#  inspect     Display detailed information on one or more containers
#  ls          List containers
#  rename      Rename a container
#  rm          Remove one or more containers
#  run         Create and run a new container from an image

#dc::docker::client::container::inspect(){
#  true
#}

#dc::docker::client::container::rename(){
#  true
#}

#Options:
#  -s, --signal string   Signal to send to the container
#  -t, --time int        Seconds to wait before killing the container
#dc::docker::client::container::stop(){
#  true
#}

#  -a, --all             Show all containers (default shows just running)
#  -f, --filter filter   Filter output based on conditions provided
#      --format string   Format output using a custom template:
#                        'table':            Print output in table format with column headers (default)
#                        'table TEMPLATE':   Print output in table format using the given Go template
#                        'json':             Print in JSON format
#                        'TEMPLATE':         Print output using the given Go template.
#                        Refer to https://docs.docker.com/go/formatting/ for more information about formatting output with templates

# Unimplemented
#  -n, --last int        Show n last created containers (includes all states) (default -1)
#  -l, --latest          Show the latest created container (includes all states)
#      --no-trunc        Don't truncate output
#  -q, --quiet           Only display container IDs
#  -s, --size            Display total file sizes
dc::docker::client::container::list(){
  local com=(container list)

  local all="${1:-}"
  [ "$all" == "" ] || com+=(--all)
  shift || true

  local format="${1:-}"
  [ "$format" == "" ] || com+=(--format "$format")
  shift || true

  local filter="${1:-}"
  [ "$filter" == "" ] || com+=(--filter "$filter")
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}

#  -f, --force     Force the removal of a running container (uses SIGKILL)
#  -l, --link      Remove the specified link
#  -v, --volumes   Remove anonymous volumes associated with the container
dc::docker::client::container::remove(){
  local com=(container remove)

  local force="${1:-}"
  [ "$force" == "" ] || com+=(--force)
  shift || true

  local volume="${1:-}"
  [ "$volume" == "" ] || com+=(--volumes)
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}

#      --annotation map                   Add an annotation to the container (passed through to the OCI runtime) (default map[])
#  -a, --attach list                      Attach to STDIN, STDOUT or STDERR
#      --blkio-weight uint16              Block IO (relative weight), between 10 and 1000, or 0 to disable (default 0)
#      --blkio-weight-device list         Block IO weight (relative device weight) (default [])
#      --cgroup-parent string             Optional parent cgroup for the container
#      --cgroupns string                  Cgroup namespace to use (host|private)
#                                         'host':    Run the container in the Docker host's cgroup namespace
#                                         'private': Run the container in its own private cgroup namespace
#                                         '':        Use the cgroup namespace as configured by the
#                                                    default-cgroupns-mode option on the daemon (default)
#      --cidfile string                   Write the container ID to the file
#      --cpu-period int                   Limit CPU CFS (Completely Fair Scheduler) period
#      --cpu-quota int                    Limit CPU CFS (Completely Fair Scheduler) quota
#      --cpu-rt-period int                Limit CPU real-time period in microseconds
#      --cpu-rt-runtime int               Limit CPU real-time runtime in microseconds
#  -c, --cpu-shares int                   CPU shares (relative weight)
#      --cpus decimal                     Number of CPUs
#      --cpuset-cpus string               CPUs in which to allow execution (0-3, 0,1)
#      --cpuset-mems string               MEMs in which to allow execution (0-3, 0,1)
#      --detach-keys string               Override the key sequence for detaching a container
#      --device-cgroup-rule list          Add a rule to the cgroup allowed devices list
#      --device-read-bps list             Limit read rate (bytes per second) from a device (default [])
#      --device-read-iops list            Limit read rate (IO per second) from a device (default [])
#      --device-write-bps list            Limit write rate (bytes per second) to a device (default [])
#      --device-write-iops list           Limit write rate (IO per second) to a device (default [])
#      --disable-content-trust            Skip image verification (default true)
#      --dns-option list                  Set DNS options
#      --dns-search list                  Set custom DNS search domains
#      --domainname string                Container NIS domain name
#      --entrypoint string                Overwrite the default ENTRYPOINT of the image
#      --env-file list                    Read in a file of environment variables
#      --gpus gpu-request                 GPU devices to add to the container ('all' to pass all GPUs)
#      --group-add list                   Add additional groups to join
#      --health-cmd string                Command to run to check health
#      --health-interval duration         Time between running the check (ms|s|m|h) (default 0s)
#      --health-retries int               Consecutive failures needed to report unhealthy
#      --health-start-interval duration   Time between running the check during the start period (ms|s|m|h) (default 0s)
#      --health-start-period duration     Start period for the container to initialize before starting health-retries countdown (ms|s|m|h) (default 0s)
#      --health-timeout duration          Maximum time to allow one check to run (ms|s|m|h) (default 0s)
#      --help                             Print usage
#      --init                             Run an init inside the container that forwards signals and reaps processes
#  -i, --interactive                      Keep STDIN open even if not attached
#      --ipc string                       IPC mode to use
#      --isolation string                 Container isolation technology
#      --kernel-memory bytes              Kernel memory limit
#      --label-file list                  Read in a line delimited file of labels
#      --link list                        Add link to another container
#      --link-local-ip list               Container IPv4/IPv6 link-local addresses
#      --log-driver string                Logging driver for the container
#      --log-opt list                     Log driver options
#  -m, --memory bytes                     Memory limit
#      --memory-reservation bytes         Memory soft limit
#      --memory-swap bytes                Swap limit equal to memory plus swap: '-1' to enable unlimited swap
#      --memory-swappiness int            Tune container memory swappiness (0 to 100) (default -1)
#      --network-alias list               Add network-scoped alias for the container
#      --no-healthcheck                   Disable any container-specified HEALTHCHECK
#      --oom-kill-disable                 Disable OOM Killer
#      --oom-score-adj int                Tune host's OOM preferences (-1000 to 1000)
#      --pid string                       PID namespace to use
#      --pids-limit int                   Tune container pids limit (set -1 for unlimited)
#      --platform string                  Set platform if server is multi-platform capable
#  -P, --publish-all                      Publish all exposed ports to random ports
#      --pull string                      Pull image before running ("always", "missing", "never") (default "missing")
#  -q, --quiet                            Suppress the pull output
#      --restart string                   Restart policy to apply when a container exits (default "no")
#      --rm                               Automatically remove the container when it exits
#      --runtime string                   Runtime to use for this container
#      --security-opt list                Security Options
#      --shm-size bytes                   Size of /dev/shm
#      --sig-proxy                        Proxy received signals to the process (default true)
#      --stop-signal string               Signal to stop the container
#      --stop-timeout int                 Timeout (in seconds) to stop a container
#      --storage-opt list                 Storage driver options for the container
#      --sysctl map                       Sysctl options (default map[])
#  -t, --tty                              Allocate a pseudo-TTY
#      --ulimit ulimit                    Ulimit options (default [])
#  -u, --user string                      Username or UID (format: <name|uid>[:<group|gid>])
#      --userns string                    User namespace to use
#      --uts string                       UTS namespace to use
#      --volume-driver string             Optional volume driver for the container
#      --volumes-from list                Mount volumes from the specified container(s)
#  -w, --workdir string                   Working directory inside the container
#      --expose list                      Expose a port or a range of ports

# What we need
#      --name string                      Assign a name to the container
#  -d, --detach                           Run container in background and print container ID
#  -h, --hostname string                  Container host name
#      --ip string                        IPv4 address (e.g., 172.30.100.104)
#      --ip6 string                       IPv6 address (e.g., 2001:db8::33)
#      --read-only                        Mount the container's root filesystem as read only
#      --privileged                       Give extended privileges to this container
#  -l, --label list                       Set meta data on a container

#      --cap-add list                     Add Linux capabilities
#      --cap-drop list                    Drop Linux capabilities
#  -e, --env list                         Set environment variables
#      --dns list                         Set custom DNS servers
#      --device list                      Add a host device to the container
#      --network network                  Connect a container to a network
#  -p, --publish list                     Publish a container's port(s) to the host
#      --tmpfs list                       Mount a tmpfs directory
#      --mount mount                      Attach a filesystem mount to the container
#  -v, --volume list                      Bind mount a volume

# What we might need
#      --mac-address string               Container MAC address (e.g., 92:d0:c6:0a:29:33)
#      --add-host list                    Add a custom host-to-IP mapping (host:ip)
dc::docker::client::container::run(){
  local com=(container run -d)

  local config="${1:-/dev/stdin}"
  local netconfig

  netconfig="$(cat "$config")"

  local name
  local image
  local hostname
  local ip
  local ip6
  local read_only
  local privileged

  local cap_add
  local cap_drop
  local dns
  local env
  local device
  local network
  local publish
  local tmpfs
  local mount
  local volume

  name="$(printf "%s" "$netconfig" | jq -r 'select(.plan.name != null).plan.name')"
  image="$(printf "%s" "$netconfig" | jq -r 'select(.plan.image != null).plan.image')"
  hostname="$(printf "%s" "$netconfig" | jq -r 'select(.plan.hostname != null).plan.hostname')"
  ip="$(printf "%s" "$netconfig" | jq -r 'select(.plan.ip != null).plan.ip')"
  ip6="$(printf "%s" "$netconfig" | jq -r 'select(.plan.ipv6 != null).plan.ip6')"
  read_only="$(printf "%s" "$netconfig" | jq -r 'select(.plan.read_only != null).plan.read_only')"
  privileged="$(printf "%s" "$netconfig" | jq -r 'select(.plan.privileged != null).plan.privileged')"

  com+=("--name" "$name")
  com+=("--hostname" "$hostname")
  [ ! "$ip" ] || com+=("--ip" "$ip")
  [ ! "$ip6" ] || com+=("--ip6" "$ip6")

  [ "$read_only" == false ] || com+=("--read-only")
  [ "$privileged" == false ] || com+=("--privileged")

  dc::argument::check name "$DC_TYPE_STRING" || return
  dc::argument::check image "$DC_TYPE_STRING" || return
  [ ! "$hostname" ] || dc::argument::check hostname "$DC_TYPE_STRING" || return
  [ ! "$read_only" ] || dc::argument::check read_only "$DC_TYPE_BOOLEAN" || return
  [ ! "$privileged" ] || dc::argument::check privileged "$DC_TYPE_BOOLEAN" || return

  cap_add="$(printf "%s" "$netconfig" | jq -r 'select(.plan.cap_add != null).plan.cap_add[]')"
  cap_drop="$(printf "%s" "$netconfig" | jq -r 'select(.plan.cap_drop != null).plan.cap_drop[]')"
  dns="$(printf "%s" "$netconfig" | jq -r 'select(.plan.dns != null).plan.dns[]')"
  env="$(printf "%s" "$netconfig" | jq -r 'select(.plan.env != null).plan.env[]')"
  device="$(printf "%s" "$netconfig" | jq -r 'select(.plan.device != null).plan.device[]')"
  network="$(printf "%s" "$netconfig" | jq -r 'select(.plan.network != null).plan.network[]')"
  publish="$(printf "%s" "$netconfig" | jq -r 'select(.plan.publish != null).plan.publish[]')"
  tmpfs="$(printf "%s" "$netconfig" | jq -r 'select(.plan.tmpfs != null).plan.tmpfs[]')"
  mount="$(printf "%s" "$netconfig" | jq -r 'select(.plan.mount != null).plan.mount[]')"
  volume="$(printf "%s" "$netconfig" | jq -r 'select(.plan.volume != null).plan.volume[]')"

  local key
  local value
  local values

  key=cap-add
  values="$cap_add"
  [ ! "$values" ] || {
    while read -r value; do
      com+=("--$key" "$value")
    done <<<"$values"
  }

  key=cap-drop
  values="$cap_drop"
  [ ! "$values" ] || {
    while read -r value; do
      com+=("--$key" "$value")
    done <<<"$values"
  }

  key=dns
  values="$dns"
  [ ! "$values" ] || {
    while read -r value; do
      com+=("--$key" "$value")
    done <<<"$values"
  }

  key="env"
  values="$env"
  [ ! "$values" ] || {
    while read -r value; do
      com+=("--$key" "$value")
    done <<<"$values"
  }

  key=device
  values="$device"
  [ ! "$values" ] || {
    while read -r value; do
      com+=("--$key" "$value")
    done <<<"$values"
  }

  key=network
  values="$network"
  [ ! "$values" ] || {
    while read -r value; do
      com+=("--$key" "$value")
    done <<<"$values"
  }

  key=publish
  values="$publish"
  [ ! "$values" ] || {
    while read -r value; do
      com+=("--$key" "$value")
    done <<<"$values"
  }

  key=tmpfs
  values="$tmpfs"
  [ ! "$values" ] || {
    while read -r value; do
      com+=("--$key" "$value")
    done <<<"$values"
  }

  key=mount
  values="$mount"
  [ ! "$values" ] || {
    while read -r value; do
      com+=("--$key" "$value")
    done <<<"$values"
  }

  key=volume
  values="$volume"
  [ ! "$values" ] || {
    while read -r value; do
      com+=("--$key" "$value")
    done <<<"$values"
  }

  while read -r label; do
    com+=(--label "$label")
  done < <(printf "%s" "$netconfig" | jq -r 'select(.labels != null).labels | . as $in| keys[] | [. + "=" + $in[.]] | add')

  _dc::docker::client::execute "${com[@]}" "$image" "$@"
}

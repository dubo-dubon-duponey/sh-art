# Develop

## TODO list

Make deployement NOT drop the connection at the end / reset everything, but make sure uncommitted plans do not get ignored before switching to a different host.

Replace all evals with `read -r "composite" <<< + export + readonly if need be`

Replace all returns $ERROR with dc::error::throw || return

Fix tests.

## Makefile

```bash
make lint
make test
make build
```

## Approach

### Requirements
- nodes
  - a heterogeneous collection of compute nodes accessible over ssh, running a container runtime
  - no orchestration layer
  - to be treated as cattle
  - would run a few to a few dozens containers
- security should be by default (read-only, cap-drop ALL) with the ability to bypass some
- networking should be highly and easily configurable (ipv6, vlan), with good defaults out of the box
- tool
  - should be able to run on different machines indifferently (no local state)
  - should be straightforward and easy to use
  - must impose no additional requirement on the target nodes
  - should have minimal dependency requirements on the running host
  - should expose a bare minimum number of options and thrive for simplicity
  - should run plans in a programmatic way (which obviously allows consuming definitions in
    whatever format - json, yaml - if desired)

### Current implementation
- is written and tested for bash 3-5
- depends on the presence of an ssh client, and jq, on the running host

Note that ssh is not technically needed, and custom clients can be used instead.
For example, passing just `docker` as the client will evidently target the local docker binary...

Philosophy:
- additional methods and options to the API should be added sparingly,
  and only if they contribute major value for the intended use-case
- programmatic API means people are free to build on top of it, outside the core
- specifically, there is a hook for custom clients implementation, and evidently
  room for implementation of custom configuration file formats for people who need them

## Known issues

Label values cannot have spaces in them.
Something weird about docker parsing arguments after ssh escaping.

Stopped containers are treated the same as others and no specific message about them is provided.

## Docker issues

Filters are garbage.
They are inconsistently implemented accross commands, and some of the documented patterns
do not even work (eg: `label!=foo` just errors out).
Just better to not rely on it and use jq instead to implement filtering properly.
Note: docker labelling is also crazily inconsistent ("Name" vs. "Names"...)


## About access control and security

We rely solely on ssh to access the hosts.
This is the ACL layer.
Managing ssh keys and authorizations is the responsibility of another tool.

## About "state"

Right now, we sha512 the definition of objects and store that on the objects themselves as a label.


ANY change to the definition means the object will be destroyed, and a new one created.
Furthermore, any object managed by us that is no longer in the plan will get garbage collected.

This works, but may leave room for improvement.

For example, some changes may be performed in place.
Though, this approach is what killed terraform-docker-provider for us, since it has done a poor job
at properly identifying idempotent properties. It also goes again the philosophy we embrace (nodes as cattle,
don't manage, redeploy).

Our approach also clearly forbids having multiple different plans executed on the same host, as
each of them would GC what the other has done. We could further tag objects with the plan name, but then,
plan renames would leave shit behind.
Then a prune command might help, but hello additional complexity, just so that mom can mismanage her cluster...

If we were to implement something stateful, that would let us track plan uuid, or previous state, we could store that
locally, but obviously we would lose the ability to execute on different machines.
We could store the state remotely, in a central service, but then this is no longer a standalone simple tool.
We could store it on the cluster, for eg, as labels on a specific container, but then again that would not solve the multiplan
problem.

All in all, this is just not worth it right now, and would need a clear use-case that we do not see here.

Also, and again unlike tf-docker, we do not try to inspect existing objects to figure out if they are consistent
with our desired state. We just rely on the sha they carry.
The downside is that outside modifications of these objects would not be picked up.
The upside is that again we do not imply anything on what the runtime does with the definitions we pass to it.
We let the container runtime decide how to interpret them and what the final result will be.

Put otherwise, for us, the desired state is the set of commands we pass to the platform, not the result of applying
these commands.

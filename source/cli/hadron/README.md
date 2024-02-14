## Hadron issues

Labels cannot have spaces.
Something weird about docker parsing arguments post ssh escaping.

## Docker issues

Filters are garbage.
They are inconsistently implemented accross commands, and some of the documented patterns
do not even work (eg: `label!=foo` just errors out).

Just better to not rely on it and use jq instead.

## Notes about state

Right now, we sha the definition of the object and store that on the object itself as a label.
ANY change to the definiion means the object will be destroyed, and a new one created.
Furthermore, any object managed by us that is no longer in the plan will get garbage collected.
This works, but may leave room for improvement.
For example, some changes may be performed in place.
Though, this approach is what killed terraform-docker-provider for us, since it has done a poor job
at properly identifying idempotent properties.
Also, our approach clearly forbids having multiple different plans executed on the same host, as
each of them would GC what the other has done. We could further tag objects with the plan name, but then,
plan renames would leave shit behind.
Then a prune command might help, but hello additional complexity, just so that mom can mismanage her cluster...

If we were to implement something stateful, that would let us track plan uuid, or previous state, we could store that
locally, but obviously we would loose the ability to execute the same on different machines.
Or store it on the cluster, for eg, as labels on a specific container, but then again would not solve the multiplan 
problem.

ALl in all, this is just not worth it right now, and would need a clear usecase to back that up.

Also, and again unlike tf-docker, we do not try to inspect existing objects to figure out if they are consistent
with our desired state. We just rely on the sha they carry.
The downside is that outside modifications of these objects would not be picked up.
The upside is that again we do not imply anything on what docker does with the properties we set.
We let docker decide how to interpret them and what the final result will be.

Put otherwise, for us, the desired state is the set of commands we pass to the platform, not the result of applying 
these commands.


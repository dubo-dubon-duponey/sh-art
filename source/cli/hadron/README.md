# Hadron

## What is this?

Hadron is a lightweight, unix command-line tool to provision containers and networks
on a fleet of heterogenous nodes in a programmatic way.

It thrives for simplicity of use, a programmatic-first approach, speed, secure defaults,
minimal dependencies, with a limited number of options and a relatively narrow use-case
(no overlay networking, no orchestration, no monitoring, no world-scale readiness).

Hadron does not aim at replacing generic, established, do-it-all provisioning and infrastructure
management tools.

We believe that infrastructure-as-code has reached a point of complexity and bloat
that now diminishes its usefulness for an ever-increasing cost of ownership for most small to
mid-size operations that do not or should not run tooling created to solve problems they will
never have.

Hadron grew out of our own frustration using these tools, for our own bite-size use-cases and 
tiny infrastructure (a dozen of nodes and a few hundreds services).

We do strongly believe in containers as the right way to ship and execute software, just not in any of the 
additional vendors layers that grew out of the ecosystem over the past ten years.
And we do believe that ssh is the only thing you should ever need to manage deployment.

We are not in the business of dealing with the initial provisioning of the nodes, nor in managing ssh keys (these are different problems
altogether that are better left to other tools), and certainly not in the business of building containers either.

What we do is deploy software on ssh+container-ready nodes.

Small, simple, does one thing well.

## TL;DR

```bash
brew install dubo-dubon-duponey/brews/hadron
```

Create a plan:
```bash
hadron::connect user host port
```

## More...

### Requirements

You need software from 2016 (or more recent):

* bash 4.4 (released in 2016)
* openssh client 7.3 (released in 2016)
* jq 1.0 (released in 2015)
* grep (released by your grand-mother)

Your target nodes should run a container runtime (docker only for now) and an ssh server.

### Installation

Alternatively, git clone the repository, then make build.

### On managed vs. unmanaged containers

For your target nodes, it is recommended to only deploy using hadron and not mix it with
other tools, or manual deployments.

For example:
- if unmanaged containers or networks use the same name as a desired Hadron object, Hadron will fail
- containers attached to a Hadron network WILL get garbage collected if the network changes

## WHY? ... and other existential questions

See [FAQ.md]

## Development

Intersted in hacking on this?
See [DEVELOP.md]

## License

MIT

## Community rules

1. Don't be an ass
2. See above

### Why another infrastructure deployment tool? What about X/Y/Z?

We have been using extensively the docker-cli, nerdctl, compose, kube, puke, ansible, chef, 
puppet, dagger, and lately, a lot of terraform / opentofu.
Not only are we, indeed, aware of their existence, but we also think they are all great products,
that certainly respond very well to some use cases.

Our own problem is the management of a collection of straight docker (or containerd) nodes though,
with no orchestration layer, in a small scale context.  Think: "a bunch of devices on a small to medium size ".
All in all, maybe one hundred containers - and no, we do not need elasticity.

At that scale, for that use case, orchestrators would not deliver any value and only bring
unwarranted complexity. At the other end of the spectrum, deploying by hand calling nerdctl or docker-cli
would quickly become cumbersome and turn into a large mess.

We have been using terraform extensively, for better or worse.
Unfortunately the docker provider is abandon-ware at this point, is in a
sad to embarrassing state (eg: ssh close), and has deal killer issues (eg: inability to specify multiple subnets).
Also, it would not work with just containerd of course.

Compose would be a relatively logical choice, but we think it has also grown needlessly complex
and unruly, not to mention the need for large dependencies and a sizable codebase.
We also disagree philosophically with many of its choices.
It also naturally targets deployments to a single docker host, leaving multi-host management as
an exercise to the reader (unless you do orchestration, which again we do not think any small-ish
size operation actually need).

### Why the name?

All my devices are named after physics particles.
This seems apt to name this project as something that smash them together.

https://en.wikipedia.org/wiki/Large_Hadron_Collider

### Why not use a proper programming language ("that I like") instead of shell?

"Proper" as you call them:
- move fast and fall out of support faster (seen golang support window?) - I
  just do not want to continuously have to upgrade runtime and codebase to match
  while leaving users of older versions out in the water
- if you mean that you could, for example "replace" shelling-out to other binaries (that you
  probably think is "not elegant") and instead use a library for, say, ssh - then: congrats! You
  just successfully introduced a huge security nightmare and a large maintenance burden for both you 
  and your users for absolutely no benefit whatsoever
- if you mean that you could have access to a large ecosystem of cool libraries
  so that you can output a dancing emoji on the command line, then congrats again (see above)

Modern, "proper" languages and platforms are good and fine for large projects with full time development teams
that create something truly new.

But let's look at the use case here:
- expose a handful of methods for the user
- serialize the output of these methods into commands to be run by ssh and fed to another system

Tell me again: why exactly do you think you need more than bash?

Yes, the unix spirit has been lost for a while...

Also, yeah, shell is cool.

### Why a programmatic approach instead of some declarative yaml/toml/json/whatnot?

Let's take a concrete example, JSON, and assume that you want one container definition to depend on the other.
container2 would use container1 ip as DNS.

Well, there is no provision in JSON to express references, so now you have to create something bespoke.
Use "@" or "$" or something like that, and follow with something like XPath for json.
Now, you will have to explain to users that they need to learn this ad-hoc not standard new syntax, and also to
remember to somehow escape the marker character if they want to have a litteral...
So, instead of "@", they need to enter "@@".

```json
{
  "definitions": [{
      "container2": {"dns": "@definitions.container1"}
    },
    {
      "container1": {"ip": "1.2.3.4"}
    }
  ]
}
```

This is already a mess.
Now, you will have to parse this, and build a dependency tree.
And solve the problem of recursive dependencies.

Guess what, some people spend their entire career becoming specialists of these problems.
There is a reason HCL got created, and cuelang.

And having used both extensively, they end-up being just as complex as any programming language, except they do that
in a very mind-fucking way that will hurt more than your feelings.

On the other hand, a programming language is something developers are already familiar with, and that provides compile time
or runtime solutions for these problems.
You can't reference an object before it is instanciated.
You can have type validation for free.
Circular dependencies won't turn into a mess (easily).
And you don't have to shake a tree. Just run the code.

Yep, configuration files are fine for simple things and simple cases.
But trying to do anything complex with them is like doing brain surgery with a shovel.
I will not judge these who do, but better someone else than me.

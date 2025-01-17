To edit a secret, cd into this directory and then run `agenix -e <secret>.age`. 

On my machine, the `EDITOR` variable unsets and I keep my age private keys seperate from my ssh keys (to limit blast radius if they were to be compromised), so the invocation to edit a key looks like this:

```
EDITOR=kak agenix -e <secret>.age -i <path to secret>
```
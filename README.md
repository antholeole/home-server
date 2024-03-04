HOME MANAGER

Hosts:
- budget
- tasks?
- food!

## getting started

The project is setup so you can open the `code-workspace` in vscode and it is very pretty. 

ports to forward:

- 8080 (hasura engine) 
- 9695 (console)
- 9693 (i have no idea but its required)
- 9600 (flutter web)

1. nix
2. direnv
3. run `direnv allow`
4. you also need to install and have a docker daemon running.
5. run `dev`
6. run `watch` to get graphql live updates to the schema as you dev.
7. For better graphql experience, `stpn.vscode-graphql` is a good vsc ext.

## useful commands:
- `seed -a nuke`: deletes the entire database
- `seed -a setup-test`: creates a default setup
- `e2e test`: Runs the e2e test. must have dev servers up
- `fetch && generate`: pulls schema changes locally, then generates all the things

## TODO 
- hook in treefmt-ni


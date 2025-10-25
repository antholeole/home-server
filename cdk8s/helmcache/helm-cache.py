import argparse
import sys
import os
import json
import subprocess
from typing import cast


class Args(argparse.Namespace):
    def __init__(self) -> None:
        super().__init__()
        self.namespace: str
        self.subcommand: str
        self.repo: str
        self.release_name: str
        self.chart_name_or_path: str
        self.helm_cache: str
        self.values: str | None


# basically, transforms a call like
# 
# helm template --repo https://emberstack.github.io/helm-charts --version 9.1.37 --namespace kubernetes-reflector reflector-helm-c851c0f3 reflector
#
#  or
# 
# helm template -f /build/cdk8s-helm-F5CzqR/overrides.yaml --repo https://charts.jetstack.io
# --version 1.19.1 --namespace cert-manager cert-manager-helm-c807a262
#
# to
# 
# cert-manager helm template cnpg-helm-c8c43f88 ./cloudnative-pg-0.26.0.tgz
def main():
    parser = argparse.ArgumentParser()

    _ = parser.add_argument("subcommand")
    _ = parser.add_argument("chart_name_or_path")
    _ = parser.add_argument("release_name")

    _ = parser.add_argument("--helm-cache", type=str)
    _ = parser.add_argument("--repo", type=str)
    _ = parser.add_argument("--version", type=str)
    _ = parser.add_argument("--namespace", type=str)
    _ = parser.add_argument("-f", "--values", type=str, required=False)

    args = cast(Args, parser.parse_args())

    if args.subcommand != "template":
        _ = subprocess.run(
            ["helm", *sys.argv[1:]],
            check=True,
            stdout=sys.stdout,
            stderr=sys.stderr,
            text=True,
        )

        return

    lookup_key = f"{args.repo}/{args.release_name}"
    with open(f"{args.helm_cache}/replace.json", "r") as f:
        chart_path: str = f"{args.helm_cache}/repocache/{json.load(f)[lookup_key]}"

        out_args: list[str] = ["helm", "template"]
        out_args.append(args.release_name)
        if args.values is not None:
            out_args.extend(["-f", args.values])

        out_args.extend(["--namespace", args.namespace])
        out_args.append(chart_path)

        print(out_args, file=sys.stderr)
        _ = subprocess.run(
            out_args, check=True, stdout=sys.stdout, stderr=sys.stderr, text=True
        )


if __name__ == "__main__":
    main()

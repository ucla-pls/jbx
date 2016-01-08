
import subprocess

def build(string):
    return subprocess.call(["nix-build", "--expr", string])

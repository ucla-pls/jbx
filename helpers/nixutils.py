
import subprocess

def build(string):
    return subprocess.call(["nix-build", "--expr", string])

def evaluate(string):
    return subprocess.call(["nix-instantiate", "--eval", "--expr", string])

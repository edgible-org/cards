#!/usr/bin/env python3
"""Scan the images the cards pin for fixable HIGH and CRITICAL vulnerabilities.

Reads every <card>/docker-compose.yml, resolves ${VAR:-default} to the default, scans each
unique image once with Trivy (a container, so the runner needs only Docker), and writes
scan.json: per image, the cards that use it and its fixable findings. Nothing is deployed.

  image_scan.py [--out scan.json] [--only CARD ...] [--issues] [--badges DIR]

--badges DIR writes <card>.json per card, in the shields.io endpoint format the README's
badges read: "clean", "N fixable", or "not scanned" when an image could not be checked.

--previous FILE is the last scan.json, which says how long an image has been flagged.

Each image also gets a state, from Renovate's Dependency Dashboard and its open pull requests:

  clean     nothing fixable
  renovate  flagged, and Renovate has a newer version on its way, which merges itself
  upstream  flagged, on the newest version: only its project can fix it
  ours      flagged, one of Edgible's images: card-kit's own-images-refresh rebuilds it
  needs-you a person has to act, and `note` says how
  (a major version counts only when a scan shows its image has fewer findings, or cannot compare it:
  most database majors carry the same findings, and are a data migration for nothing)
  skipped   not scanned on purpose: built on the machine, in Renovate's ignoreDeps

--issues keeps one issue, Image health, that lists only what needs a person, and is closed
when nothing does (needs `gh` and a token that may read pull requests and write issues).
"""
import argparse
import json
import re
import subprocess
import sys
import time
from collections import defaultdict
from datetime import date
from pathlib import Path

TRIVY = "ghcr.io/aquasecurity/trivy:0.76.1"
CACHE = "trivy-cache"
LABEL = "security-scan"
ISSUE = "Image health"
OURS = "ghcr.io/edgible-org/"
OURS_DAYS = 7       # own-images-refresh has had this long, and something is in its way
CRITICAL_DAYS = 30  # a critical finding with no release to bump to is worth a look, not an alarm
UPDATE = re.compile(r"Update (.+?)( Docker (?:tag|digest)| monorepo)? to ([^\s\]]+)")
IMAGE = re.compile(r"^\s*image:\s*(\S+)", re.M)
VAR = re.compile(r"\$\{[A-Za-z0-9_]+:-([^}]*)\}")


def images_by_card(root: Path, only: list[str]) -> dict[str, set[str]]:
    found: dict[str, set[str]] = defaultdict(set)
    for compose in sorted(root.glob("*/docker-compose.yml")):
        card = compose.parent.name
        if only and card not in only:
            continue
        for ref in IMAGE.findall(compose.read_text()):
            ref = VAR.sub(r"\1", ref).strip("\"'")
            if "${" not in ref:
                found[ref].add(card)
    return found


def scan(ref: str) -> dict:
    cmd = ["docker", "run", "--rm", "-v", f"{CACHE}:/root/.cache", TRIVY, "image", "--quiet",
           "--format", "json", "--severity", "HIGH,CRITICAL", "--ignore-unfixed",
           "--scanners", "vuln", "--timeout", "15m", ref]
    done = subprocess.run(cmd, capture_output=True, text=True)
    if done.returncode != 0:  # usually a registry's passing refusal
        time.sleep(30)
        done = subprocess.run(cmd, capture_output=True, text=True)
    if done.returncode != 0:
        return {"error": done.stderr.strip().splitlines()[-1] if done.stderr.strip() else "scan failed"}
    findings = []
    for result in json.loads(done.stdout or "{}").get("Results", []):
        for v in result.get("Vulnerabilities") or []:
            findings.append({"id": v["VulnerabilityID"], "severity": v["Severity"],
                             "package": v["PkgName"], "installed": v["InstalledVersion"],
                             "fixed": v.get("FixedVersion", "")})
    return {"findings": findings}


def repo_of(ref: str) -> str:
    """The image without its tag, digest, or Docker Hub's default prefixes."""
    name = ref.split("@")[0].removeprefix("docker.io/").removeprefix("library/")
    return re.sub(r":[^/]+$", "", name)


def update_for(repo: str, updates: dict[str, str]) -> str | None:
    """A Renovate name is the image or, for a group, "monorepo:" and a word in its name (immich)."""
    return next((text for name, text in updates.items()
                 if name == repo or (name.startswith("monorepo:") and name[9:] in repo)), None)


def key_of(match: re.Match) -> str:
    return ("monorepo:" if match.group(2) == " monorepo" else "") + match.group(1)


def newer_major(ref: str, target: str) -> bool:
    """Renovate lists one major per image name, which a card on a later tag may already have passed."""
    tag = ref.split("@")[0].rpartition(":")[2]
    have, want = re.match(r"v?(\d+)", tag), re.match(r"v?(\d+)", target)
    return not (have and want) or int(want[1]) > int(have[1])


def gh_json(*args: str):
    return json.loads(subprocess.run(["gh", *args], capture_output=True, text=True, check=True).stdout)


def renovate_state() -> dict[str, dict[str, str]]:
    """From the Dependency Dashboard: what awaits a yes (majors) and what is on its way, and from
    the open pull requests, the bumps that failed their tests. Each is {image name: text}."""
    state: dict[str, dict[str, str]] = {"majors": {}, "coming": {}, "failing": {}}
    found = gh_json("issue", "list", "--search", "Dependency Dashboard in:title", "--state", "open",
                    "--json", "number,body,title")
    board = next((i for i in found if i["title"] == "Dependency Dashboard"), None)
    section = ""
    for line in (board["body"] if board else "").splitlines():
        if line.startswith("## "):
            section = line[3:].strip()
        if section == "Detected Dependencies":
            break
        m = UPDATE.search(line)
        if not m or section.startswith("PR Closed"):
            continue
        target = state["majors"] if section == "Pending Approval" else state["coming"]
        target[key_of(m)] = m.group(3)
    for pr in gh_json("pr", "list", "--state", "open", "--author", "app/renovate", "--limit", "50",
                      "--json", "title,url,statusCheckRollup"):
        m = UPDATE.search(pr["title"])
        if m and any(c.get("conclusion") in ("FAILURE", "TIMED_OUT") for c in pr["statusCheckRollup"]):
            state["failing"][key_of(m)] = pr["url"]
    return state


def major_ref(ref: str, target: str) -> str:
    """The image a major version would be, as Renovate names only the number: the version part of
    the tag becomes that number, and any suffix stays (postgres:17.11-alpine, v18: postgres:18-alpine)."""
    name, _, tag = ref.split("@")[0].rpartition(":")
    number = target.lstrip("v")
    m = re.match(r"(v?)\d+(?:\.\d+)*(.*)", tag)
    return f"{name}:{m[1]}{number}{m[2]}" if m else f"{name}:{number}"


def counts(findings: list[dict]) -> tuple[int, int]:
    return len(findings), sum(f["severity"] == "CRITICAL" for f in findings)


def add_states(report: dict, previous: dict, renovate: dict, ignored: set[str], today: date,
               scan_major=scan) -> None:
    """Give each image its state and, when a person has to act, a note. An image's dates follow its
    name, so a bump that does not clear a finding does not restart the clock."""
    scanned_majors: dict[str, dict] = {}  # several tags can point to one major image
    def earliest(field: str, repo: str) -> str:
        dates = [i[field] for r, i in previous.items() if repo_of(r) == repo and i.get(field)]
        return min(dates, default=today.isoformat())

    for ref, item in report.items():
        repo = repo_of(ref)
        findings = item.get("findings") or []
        critical = any(f["severity"] == "CRITICAL" for f in findings)
        if findings:
            item["flagged_since"] = earliest("flagged_since", repo)
        if critical:
            item["critical_since"] = earliest("critical_since", repo)
        days = lambda field: (today - date.fromisoformat(item[field])).days

        failing = update_for(repo, renovate["failing"])
        major = update_for(repo, renovate["majors"])
        if repo in ignored:
            item["state"] = "skipped"
        elif "error" in item:
            item["state"], item["note"] = "needs-you", "could not be scanned: " + item["error"][:160]
        elif not findings:
            item["state"] = "clean"
        elif ref.startswith(OURS):
            if days("flagged_since") > OURS_DAYS:
                item["state"] = "needs-you"
                item["note"] = (f"our own image, flagged for {days('flagged_since')} days: the nightly "
                                "own-images-refresh in card-kit has not cleared it")
            else:
                item["state"] = "ours"
        elif failing:
            item["state"], item["note"] = "needs-you", f"Renovate's bump failed its test: {failing}"
        elif update_for(repo, renovate["coming"]):
            item["state"] = "renovate"
        elif major and newer_major(ref, major):
            target = major_ref(ref, major)
            result = scanned_majors.setdefault(target, scan_major(target))
            have, have_critical = counts(findings)
            if "error" in result:
                item["state"] = "needs-you"
                item["note"] = (f"major version {major} is available, but `{target}` could not be scanned to "
                                f"compare with {have} findings now; check its real tag on the Dependency Dashboard")
            else:
                new, new_critical = counts(result["findings"])
                item["major"] = {"image": target, "findings": new, "critical": new_critical}
                if new < have:
                    item["state"] = "needs-you"
                    item["note"] = (f"major version {major} has fewer findings: {have} ({have_critical} critical) now, "
                                    f"{new} ({new_critical} critical) in `{target}`. It can need a data migration, "
                                    "so it waits for a yes on the Dependency Dashboard")
                else:
                    item["state"] = "upstream"
        else:
            item["state"] = "upstream"
        if item["state"] == "upstream" and critical and days("critical_since") > CRITICAL_DAYS:
            item["long_critical"] = days("critical_since")


def sync_issue(report: dict) -> None:
    """One issue: what needs a person, and how many images are in each state."""
    needed = [(ref, i) for ref, i in report.items() if i["state"] == "needs-you"]
    counts = defaultdict(int)
    for item in report.values():
        counts[item["state"]] += 1
    lines = [f"- `{ref}` ({', '.join(i['cards'])}): {i['note']}" for ref, i in sorted(needed)]
    # Most images wait on their project at some point, so an old finding is worth a look, not a person's
    # action: on its own it keeps the issue closed.
    old = [f"- `{ref}` ({', '.join(i['cards'])}): {i['long_critical']} days"
           for ref, i in sorted(report.items()) if i.get("long_critical")]
    body = "\n".join([
        f"The nightly image scan, on {len(report)} images. This lists only what needs a person; "
        "the rest looks after itself, and the detail is in "
        "[scan.json](https://github.com/edgible-org/cards/blob/scan-status/scan.json).", "",
        *(["## Needs you", "", *lines, ""] if lines else ["Nothing needs you.", ""]),
        "## Everything else", "",
        f"- Clean: {counts['clean']}",
        f"- Renovate has a newer version on its way: {counts['renovate']}",
        f"- On the newest version, waiting on its project: {counts['upstream']}",
        f"- Our own images, for the nightly rebuild: {counts['ours']}",
        *(["", f"## Critical for over {CRITICAL_DAYS} days, with no release to bump to", "",
           "Worth a look when convenient: keep the image, or choose another.", "", *old] if old else []),
    ])
    found = gh_json("issue", "list", "--label", LABEL, "--state", "all", "--search", f"{ISSUE} in:title",
                    "--json", "number,title,state")
    issue = next((i for i in found if i["title"] == ISSUE), None)
    if not issue:
        if needed:
            subprocess.run(["gh", "issue", "create", "--title", ISSUE, "--body", body, "--label", LABEL], check=True)
        return
    subprocess.run(["gh", "issue", "edit", str(issue["number"]), "--body", body], check=True)
    if needed and issue["state"] == "CLOSED":
        subprocess.run(["gh", "issue", "reopen", str(issue["number"])], check=True)
    if not needed and issue["state"] == "OPEN":
        subprocess.run(["gh", "issue", "close", str(issue["number"]), "--comment", "Nothing needs a person now."], check=True)


def write_badges(report: dict, root: Path, out: Path) -> None:
    out.mkdir(parents=True, exist_ok=True)
    for card_yml in sorted(root.glob("*/card.yml")):
        card = card_yml.parent.name
        items = [i for i in report.values() if card in i["cards"]]
        found = [f for i in items for f in i.get("findings", [])]
        if found:
            critical = any(f["severity"] == "CRITICAL" for f in found)
            message, color = f"{len(found)} fixable", "red" if critical else "orange"
        elif any("error" in i for i in items):
            message, color = "not scanned", "lightgrey"
        elif items:
            message, color = "clean", "brightgreen"
        else:
            message, color = "no images", "lightgrey"
        (out / f"{card}.json").write_text(json.dumps(
            {"schemaVersion": 1, "label": "images", "message": message, "color": color}) + "\n")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="scan.json")
    ap.add_argument("--only", nargs="*", default=[])
    ap.add_argument("--issues", action="store_true")
    ap.add_argument("--badges", type=Path)
    ap.add_argument("--previous", type=Path)
    args = ap.parse_args()

    images = images_by_card(Path.cwd(), args.only)
    report = {}
    for ref in sorted(images):
        print(f"scanning {ref}", file=sys.stderr)
        report[ref] = {"cards": sorted(images[ref]), **scan(ref)}
    previous = json.loads(args.previous.read_text()) if args.previous and args.previous.is_file() else {}
    ignored = set(json.loads(Path("renovate.json").read_text()).get("ignoreDeps", []))
    add_states(report, previous, renovate_state(), ignored, date.today())
    Path(args.out).write_text(json.dumps(report, indent=2) + "\n")

    bad = {r: i for r, i in report.items() if i.get("findings")}
    broken = {r: i for r, i in report.items() if "error" in i}
    print(f"{len(report)} images: {len(bad)} with fixable findings, {len(broken)} not scanned")
    for ref, item in bad.items():
        print(f"  {ref} ({', '.join(item['cards'])}): {len(item['findings'])} findings")
    for ref, item in broken.items():
        print(f"  not scanned {ref}: {item['error']}")
    if args.badges:
        write_badges(report, Path.cwd(), args.badges)
    if args.issues:
        sync_issue(report)
    return 0


if __name__ == "__main__":
    sys.exit(main())

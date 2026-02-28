#!/usr/bin/env python3
"""
github_scout.py - GitHub repo search tool for Devil's Claw
Input  (stdin):  {"query": "...", "max_results": 8}
Output (stdout): {"repos": [...], "error": null}
"""

import json
import os
import sys
import httpx


def search_repos(query: str, max_results: int = 8) -> list[dict]:
    token = os.environ.get("GITHUB_TOKEN", "")
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    response = httpx.get(
        "https://api.github.com/search/repositories",
        params={
            "q": query,
            "sort": "stars",
            "order": "desc",
            "per_page": max_results,
        },
        headers=headers,
        timeout=30,
    )
    response.raise_for_status()
    data = response.json()

    repos = []
    for r in data.get("items", []):
        repos.append({
            "name": r.get("full_name", ""),
            "url": r.get("html_url", ""),
            "description": r.get("description", ""),
            "stars": r.get("stargazers_count", 0),
            "language": r.get("language", ""),
            "updated_at": r.get("updated_at", "")[:10],
        })
    return repos


def main() -> None:
    try:
        payload = json.loads(sys.stdin.read())
        query = payload["query"]
        max_results = payload.get("max_results", 8)
        repos = search_repos(query, max_results)
        print(json.dumps({"repos": repos, "error": None}))
    except Exception as e:
        print(json.dumps({"repos": [], "error": str(e)}))
        sys.exit(1)


if __name__ == "__main__":
    main()

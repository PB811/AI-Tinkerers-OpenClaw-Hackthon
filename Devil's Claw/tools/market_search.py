#!/usr/bin/env python3
"""
market_search.py - Tavily web search tool for Devil's Claw
Input  (stdin):  {"query": "...", "max_results": 5}
Output (stdout): {"results": [...], "error": null}
"""

import json
import os
import sys
import httpx


def search(query: str, max_results: int = 5) -> list[dict]:
    api_key = os.environ.get("TAVILY_API_KEY", "")
    if not api_key:
        raise ValueError("TAVILY_API_KEY environment variable not set")

    response = httpx.post(
        "https://api.tavily.com/search",
        json={
            "api_key": api_key,
            "query": query,
            "max_results": max_results,
            "search_depth": "advanced",
            "include_answer": False,
            "include_raw_content": False,
        },
        timeout=30,
    )
    response.raise_for_status()
    data = response.json()

    results = []
    for r in data.get("results", []):
        results.append({
            "title": r.get("title", ""),
            "url": r.get("url", ""),
            "snippet": r.get("content", ""),
            "score": r.get("score", 0.0),
        })
    return results


def main() -> None:
    try:
        payload = json.loads(sys.stdin.read())
        query = payload["query"]
        max_results = payload.get("max_results", 5)
        results = search(query, max_results)
        print(json.dumps({"results": results, "error": None}))
    except Exception as e:
        print(json.dumps({"results": [], "error": str(e)}))
        sys.exit(1)


if __name__ == "__main__":
    main()

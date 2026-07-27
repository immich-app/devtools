# Security Policy

## Reporting a Vulnerability

Please report security issues via https://github.com/immich-app/immich/security/advisories/new or to `security@immich.app`

## Scope

The following are out of scope:

* Surrounding infrastructure (redis, postgres, admin additions like reverse proxy configuration): These are the admin's responsibility.
* Attacks that require an attacker to already be an authenticated administrator: The Immich admin is already the owner of the machine.
* Network access to immich-machine-learning: It should not be made accessible outside of the container network. An attack smuggled via immich-server is still in scope.
* Automated scanner output with no demonstrable impact.
* Login hardening features, specifically rate limiting and MFA: These should be delegated to an OAuth server.
* Resource exhaustion by an authenticated user through mechanisms that are normally expected to consume significant resources.
* Installations that don't use our official container images

## LLM-assisted reports

If you use an LLM to help find or describe an issue, you must confirm the behaviour yourself and include a tested step-by-step reproduction against a fresh Immich instance. 

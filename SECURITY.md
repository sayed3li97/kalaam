# Security Policy

## Reporting a vulnerability

Please report security issues **privately** — do not open a public issue.

- Use GitHub's **[Private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)**
  (Security tab → "Report a vulnerability"), or
- email the maintainers at `security@example.com` *(replace with a real address)*.

We aim to acknowledge within 72 hours.

## Secrets & API keys

This repo is built to be safe to fork:

- `lib/firebase_options.dart`, `**/google-services.json`, `**/GoogleService-Info.plist`,
  and `firebase.json` are **git-ignored**. Only `*.example` templates are tracked. Never
  commit real config.
- A Firebase client API key is an *identifier*, not a secret — but it gates **billable**
  Gemini Developer API quota. Protect it:
  - Turn on **[Firebase App Check](https://firebase.google.com/docs/app-check)** and enforce
    it on the Generative Language API (the app initializes App Check in `main.dart`).
  - Restrict each API key to its app/API in the Google Cloud console.
  - Set a **billing budget alert** on the project.
- If you suspect a key has leaked, **rotate it** in the Google Cloud console immediately.

## Supported versions

This is a demo/sample project; only the latest `main` is supported.

# Branch Protection 설정 가이드

## Main 브랜치 보호 설정

```yaml
Branch: main
Protection Rules:
  - Require pull request reviews before merging: ✅
    - Required approving reviews: 2
    - Dismiss stale reviews: ✅
    - Require review from CODEOWNERS: ✅
    - Restrict pushes that create files: ✅
  
  - Require status checks before merging: ✅
    - Require branches to be up to date: ✅
    - Status checks: 
      - CI Tests
      - Security Scan
      - Code Quality
  
  - Require linear history: ✅
  - Include administrators: ✅
  - Restrict pushes: ✅
  - Allow force pushes: ❌
  - Allow deletions: ❌
```

## Develop 브랜치 보호 설정

```yaml
Branch: develop  
Protection Rules:
  - Require pull request reviews before merging: ✅
    - Required approving reviews: 1
    - Dismiss stale reviews: ✅
    - Require review from CODEOWNERS: ✅
  
  - Require status checks before merging: ✅
    - Status checks:
      - CI Tests
      - Lint Check
  
  - Restrict pushes: ✅
  - Allow force pushes: ❌
```

## Release 브랜치 보호 설정

```yaml
Branch Pattern: release/*
Protection Rules:
  - Require pull request reviews before merging: ✅
    - Required approving reviews: 3 (Main용), 1 (Develop용)
    - Require review from CODEOWNERS: ✅
    - Restrict dismissal of reviews: ✅
  
  - Require status checks before merging: ✅
  - Include administrators: ✅
```

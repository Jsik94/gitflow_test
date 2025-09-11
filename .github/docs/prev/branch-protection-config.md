# Branch Protection 설정 가이드 (2024년 최신)

## 🎯 **현재 구현된 워크플로우 기반 설정**

본 가이드는 현재 구현된 4개 워크플로우를 기준으로 작성되었습니다:
- `pr-template-selector.yml` - PR 템플릿 & 리뷰어 자동 할당
- `auto-labeler.yml` - 자동 라벨링
- `pr-branch-validation.yml` - GitFlow 브랜치 방향 검증
- `github-flow-option.yml` - GitHub Flow 대안 검증 (비활성화)

## 🔒 **Main 브랜치 보호 설정 (필수)**

### **Repository Settings → Branches → Add rule**

```yaml
Branch: main
Protection Rules:
  - Require pull request reviews before merging: ✅
    - Required approving reviews: 1 (개인) / 2 (팀)
    - Dismiss stale reviews: ✅
    - Require review from CODEOWNERS: ✅
    - Restrict pushes that create files: ✅
  
  - Require status checks before merging: ✅
    - Require branches to be up to date: ✅
    - Status checks (현재 워크플로우 기준):
      ✅ PR Template Selector & Auto Assignment
      ✅ Auto Labeler  
      ✅ GitFlow Branch Validation
      ❌ github-flow-option (비활성화됨)
  
  - Require linear history: ✅
  - Include administrators: ✅ (권장)
  - Restrict pushes: ✅
  - Allow force pushes: ❌
  - Allow deletions: ❌
```

## 🚀 **Develop 브랜치 보호 설정 (GitFlow)**

```yaml
Branch: develop  
Protection Rules:
  - Require pull request reviews before merging: ✅
    - Required approving reviews: 1
    - Dismiss stale reviews: ✅
    - Require review from CODEOWNERS: ✅
  
  - Require status checks before merging: ✅
    - Require branches to be up to date: ✅
    - Status checks:
      ✅ PR Template Selector & Auto Assignment
      ✅ Auto Labeler
      ✅ GitFlow Branch Validation
  
  - Restrict pushes: ✅
  - Allow force pushes: ❌
  - Include administrators: ✅ (선택사항)
```

## 📦 **Release 브랜치 보호 설정**

```yaml
Branch Pattern: release/*
Protection Rules:
  - Require pull request reviews before merging: ✅
    - Required approving reviews: 
      * → main: 2명 이상 (릴리즈 승인)
      * → develop: 1명 (백머지)
    - Require review from CODEOWNERS: ✅
    - Restrict dismissal of reviews: ✅
  
  - Require status checks before merging: ✅
    - Status checks:
      ✅ GitFlow Branch Validation (방향 검증)
      ✅ Auto Labeler (type:release 자동 적용)
  
  - Include administrators: ✅
```

## 🚨 **Hotfix 브랜치 보호 설정**

```yaml
Branch Pattern: hotfix/*
Protection Rules:
  - Require pull request reviews before merging: ✅
    - Required approving reviews: 2명 (긴급성 고려)
    - Require review from CODEOWNERS: ✅
  
  - Require status checks before merging: ✅
    - Status checks:
      ✅ GitFlow Branch Validation
      ✅ Auto Labeler (type:hotfix 자동 적용)
  
  - Include administrators: ✅
  - Restrict pushes: ✅
```

## ⚙️ **GitHub CLI를 통한 자동 설정**

### **Main 브랜치 보호 설정**
```bash
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{
    "strict": true,
    "contexts": [
      "PR Template Selector & Auto Assignment",
      "Auto Labeler", 
      "GitFlow Branch Validation"
    ]
  }' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  }' \
  --field restrictions=null
```

### **Develop 브랜치 보호 설정**
```bash
gh api repos/:owner/:repo/branches/develop/protection \
  --method PUT \
  --field required_status_checks='{
    "strict": true,
    "contexts": [
      "PR Template Selector & Auto Assignment",
      "Auto Labeler",
      "GitFlow Branch Validation"
    ]
  }' \
  --field required_pull_request_reviews='{
    "required_approving_review_count": 1,
    "require_code_owner_reviews": true
  }'
```

## 🔄 **현재 워크플로우와 연동된 설정**

### **1. CODEOWNERS 연동**
- **파일**: `.github/CODEOWNERS`
- **현재 설정**: `* @jsik94` (개인 레포)
- **팀 환경 확장**: `* @jsik94 @teammate1 @teammate2`

### **2. 자동 라벨 요구사항**
- **필요 라벨**: 13개 (labels.yml 참조)
- **자동 적용**: `auto-labeler.yml`이 브랜치/제목 기반 라벨링
- **수동 설정**: GitHub Settings → Issues → Labels

### **3. PR 템플릿 연동**
- **템플릿 디렉토리**: `.github/PULL_REQUEST_TEMPLATE/`
- **자동 선택**: `pr-template-selector.yml`이 브랜치 패턴별 적용
- **템플릿 종류**: feature.md, fix.md, hotfix-main.md, release-main.md, release-backmerge.md

## 📋 **상태 검사 (Status Checks) 세부 설정**

### **필수 상태 검사 (Required)**
```yaml
GitFlow 환경:
✅ PR Template Selector & Auto Assignment
✅ Auto Labeler  
✅ GitFlow Branch Validation

GitHub Flow 환경 (선택적):
✅ GitFlow Branch Validation (Alternative)
```

### **추가 권장 상태 검사**
```yaml
CI/CD (추가 구현 필요):
- Unit Tests
- Integration Tests
- Code Quality (SonarQube/CodeClimate)
- Security Scan (SAST/DAST)
- Dependency Check
```

## 🎯 **환경별 권장 설정**

### **개인 레포 (현재 상태)**
```yaml
main:
  - Reviews: 1명
  - CODEOWNERS: 본인
  - Status checks: 현재 3개 워크플로우

develop:
  - Reviews: 1명  
  - Status checks: 현재 3개 워크플로우
```

### **팀 레포 (확장 시)**
```yaml
main:
  - Reviews: 2명 이상
  - CODEOWNERS: 팀 리드 + 도메인 전문가
  - Status checks: 현재 워크플로우 + CI/CD

develop:
  - Reviews: 1명 이상
  - Status checks: 현재 워크플로우 + CI/CD
```

## 🚧 **특수 상황 처리**

### **1. 긴급 상황 (Emergency Override)**
```bash
# 임시 보호 규칙 해제 (관리자만)
gh api repos/:owner/:repo/branches/main/protection \
  --method DELETE

# 긴급 푸시 후 즉시 재설정
```

### **2. 릴리즈 시즌**
```yaml
# 릴리즈 기간 중 더 엄격한 설정
main:
  - Reviews: 3명 (릴리즈 매니저 + 2명)
  - 추가 상태 검사: Security Scan 필수
```

### **3. 개발 초기 (유연한 설정)**
```yaml
develop:
  - Reviews: 0명 (코드 리뷰 선택적)
  - Status checks: 기본 워크플로우만
```

## 📊 **현재 상태 점검 체크리스트**

### **설정 완료 확인**
- [ ] **Main 브랜치 보호 규칙** 활성화
- [ ] **Develop 브랜치 보호 규칙** 활성화  
- [ ] **Status Checks** 3개 워크플로우 등록
- [ ] **CODEOWNERS** 파일 설정
- [ ] **PR 템플릿** 5개 생성
- [ ] **GitHub 라벨** 13개 설정

### **워크플로우 동작 확인**
- [ ] **템플릿 자동 선택** 정상 작동
- [ ] **리뷰어 자동 할당** 정상 작동 (팀 환경)
- [ ] **Assignee 자동 설정** 정상 작동
- [ ] **자동 라벨링** 정상 작동
- [ ] **브랜치 방향 검증** 정상 작동

## 🎯 **빠른 설정 스크립트**

```bash
#!/bin/bash
# branch-protection-setup.sh

echo "🔒 Branch Protection 설정 시작..."

# Main 브랜치 보호
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["PR Template Selector & Auto Assignment","Auto Labeler","GitFlow Branch Validation"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":true}'

# Develop 브랜치 보호  
gh api repos/:owner/:repo/branches/develop/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["PR Template Selector & Auto Assignment","Auto Labeler","GitFlow Branch Validation"]}' \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"require_code_owner_reviews":true}'

echo "✅ Branch Protection 설정 완료!"
```

**이제 GitHub 저장소가 완전한 GitFlow 자동화와 함께 안전하게 보호됩니다!** 🛡️
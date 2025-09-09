# Gitflow 브랜치 전략 및 PR 방향 제어 가이드

## 🌊 Gitflow 브랜치 구조

```
main/master     ←-- 프로덕션 릴리즈
    ↑
develop         ←-- 개발 통합 브랜치
  ↗   ↖
feature/*       ←-- 기능 개발
fix/*           ←-- 버그 수정
  ↘   ↗
hotfix/*        ←-- 긴급 수정 (main에서 분기)
release/*       ←-- 릴리즈 준비
```

## ✅ 허용되는 PR 방향

### 📝 **1. Feature 개발 플로우**
```bash
# 브랜치 생성
git checkout develop
git checkout -b feature/user-authentication

# PR 방향
feature/user-authentication → develop ✅
feature/user-authentication → main ❌
```

**PR 제목 예시**:
```
feat: 사용자 인증 시스템 추가
feat(auth): JWT 토큰 기반 인증 구현
```

### 🐛 **2. 버그 수정 플로우**
```bash
# 브랜치 생성
git checkout develop  
git checkout -b fix/login-error

# PR 방향
fix/login-error → develop ✅
fix/login-error → main ❌
```

**PR 제목 예시**:
```
fix: 로그인 시 세션 만료 오류 수정
fix(auth): 비밀번호 검증 로직 개선
```

### 🚨 **3. 긴급 핫픽스 플로우**
```bash
# 브랜치 생성 (main에서)
git checkout main
git checkout -b hotfix/security-patch

# PR 방향
hotfix/security-patch → main ✅
hotfix/security-patch → develop ❌
```

**PR 제목 예시**:
```
hotfix: 보안 취약점 긴급 패치
hotfix: 결제 시스템 오류 수정
```

### 🚀 **4. 릴리즈 플로우**
```bash
# 브랜치 생성 (develop에서)
git checkout develop
git checkout -b release/v1.2.0

# PR 방향 (두 단계)
release/v1.2.0 → main ✅ (릴리즈)
release/v1.2.0 → develop ✅ (백머지)
```

**PR 제목 예시**:
```
release: v1.2.0 (main으로)
chore(backmerge): v1.2.0 (develop으로)
```

### 🔄 **5. 백머지 플로우**
```bash
# 릴리즈 후 백머지
main → develop ✅
master → develop ✅
```

**PR 제목 예시**:
```
chore(backmerge): v1.2.0
```

## 🚫 금지되는 PR 방향

### ❌ **잘못된 방향들**
```bash
# Feature가 main으로 직접 병합
feature/new-feature → main ❌

# Fix가 main으로 직접 병합  
fix/bug-fix → main ❌

# Hotfix가 develop으로 병합
hotfix/urgent-fix → develop ❌

# Main이 feature로 병합
main → feature/something ❌

# Develop이 feature로 병합
develop → feature/something ❌
```

## 🤖 자동 검증 시스템

### **1. GitHub Actions 검증**
`.github/workflows/pr-branch-validation.yml`에서:

```yaml
# 실시간 PR 방향 검증
- feature/* → develop만 허용
- fix/* → develop만 허용  
- hotfix/* → main/master만 허용
- release/* → main/master 또는 develop 허용
- develop → main/master만 허용
- main/master → develop만 허용
```

### **2. 브랜치 보호 규칙**
GitHub Settings에서 설정:

```
main 브랜치:
✅ PR 필수
✅ 상태 검사 필수
✅ 선형 히스토리 필수
✅ 관리자도 규칙 적용

develop 브랜치:  
✅ PR 필수
✅ 상태 검사 필수
```

## 📋 실제 시나리오 예시

### **시나리오 1: 새 기능 개발**
```bash
1. develop에서 브랜치 생성
   git checkout develop
   git checkout -b feature/payment-integration

2. 개발 완료 후 PR 생성
   feature/payment-integration → develop
   
3. 제목: "feat: 결제 시스템 통합 구현"
   
4. 자동 검증 결과: ✅ 통과
```

### **시나리오 2: 긴급 핫픽스**
```bash
1. main에서 브랜치 생성
   git checkout main
   git checkout -b hotfix/payment-error

2. 수정 완료 후 PR 생성
   hotfix/payment-error → main
   
3. 제목: "hotfix: 결제 API 오류 긴급 수정"
   
4. 자동 검증 결과: ✅ 통과
5. 릴리즈 후 develop으로 백머지 필요
```

### **시나리오 3: 릴리즈 프로세스**
```bash
1. develop에서 릴리즈 브랜치 생성
   git checkout develop
   git checkout -b release/v1.3.0

2. 릴리즈 준비 후 main으로 PR
   release/v1.3.0 → main
   제목: "release: v1.3.0"
   
3. main 릴리즈 완료 후 develop으로 백머지
   release/v1.3.0 → develop (또는 main → develop)
   제목: "chore(backmerge): v1.3.0"
```

### **시나리오 4: 잘못된 PR (자동 차단)**
```bash
1. 잘못된 PR 생성
   feature/new-ui → main ❌
   
2. 자동 검증 결과: ❌ 실패
   오류 메시지: "Feature branches can only merge into develop"
   
3. 올바른 방향으로 재생성 필요
   feature/new-ui → develop ✅
```

## ⚙️ 설정 방법 요약

### **1. GitHub Settings (필수)**
```
Repository → Settings → Branches → Add rule

main 브랜치:
- Require a pull request before merging ✅
- Require status checks to pass ✅  
- Require branches to be up to date ✅
- Restrict pushes that create files ✅

develop 브랜치:
- Require a pull request before merging ✅
- Require status checks to pass ✅
```

### **2. GitHub Actions (자동화)**
- `.github/workflows/pr-branch-validation.yml`
- 실시간 브랜치 방향 검증
- 위반 시 PR 차단 및 코멘트

### **3. PR 린트 규칙 (통합)**
- `.github/pr-lint/rules.json`
- 브랜치 방향 규칙 정의
- 템플릿별 검증 로직

이 설정으로 Gitflow 전략을 완벽하게 자동화하고 제어할 수 있습니다! 🎉

# 자동 라벨링 예시 시나리오

이 문서는 브랜치명과 PR 제목에 따라 어떤 라벨이 자동으로 적용되는지 보여주는 예시들입니다.

## 🌟 브랜치 기반 자동 라벨링

### 기능 개발 브랜치
```
브랜치명: feature/user-authentication
결과 라벨: type:feature

브랜치명: feat/payment-integration  
결과 라벨: type:feature
```

### 버그 수정 브랜치
```
브랜치명: fix/login-error
결과 라벨: type:fix

브랜치명: bugfix/memory-leak-issue
결과 라벨: type:fix
```

### 긴급 핫픽스 브랜치
```
브랜치명: hotfix/security-vulnerability
결과 라벨: type:hotfix, priority:high

브랜치명: hotfix/critical-payment-bug
결과 라벨: type:hotfix, priority:high
```

### 릴리스 브랜치
```
브랜치명: release/v1.2.0
결과 라벨: type:release, versioning:semver

브랜치명: rel/2024-q1-release
결과 라벨: type:release, versioning:semver
```

### 동기화/백머지 브랜치
```
브랜치명: sync/main-to-develop
결과 라벨: sync:release→develop

브랜치명: merge/backmerge-after-release
결과 라벨: sync:release→develop
```

## 📝 제목 기반 자동 라벨링

### Conventional Commits 스타일

#### 기능 추가
```
제목: feat: add user profile management
결과 라벨: type:feature

제목: feat(auth): implement OAuth2 integration
결과 라벨: type:feature

제목: feat!: breaking changes to API structure
결과 라벨: type:feature, versioning:semver
```

#### 버그 수정
```
제목: fix: resolve payment gateway timeout
결과 라벨: type:fix

제목: fix(ui): correct button alignment issue
결과 라벨: type:fix
```

#### 핫픽스
```
제목: hotfix: patch critical security vulnerability
결과 라벨: type:hotfix, priority:high

제목: hotfix(api): fix data corruption bug
결과 라벨: type:hotfix, priority:high
```

### 한국어 제목 패턴

#### 기능 관련
```
제목: 기능: 사용자 프로필 관리 시스템 추가
결과 라벨: type:feature

제목: feature 결제 모듈 통합 구현
결과 라벨: type:feature
```

#### 수정 관련
```
제목: 수정: 로그인 오류 해결
결과 라벨: type:fix

제목: 버그 수정 - 메모리 누수 문제
결과 라벨: type:fix
```

#### 긴급 상황
```
제목: 긴급: 보안 취약점 패치
결과 라벨: type:hotfix, priority:high

제목: 핫픽스 - 결제 시스템 중단 오류
결과 라벨: type:hotfix, priority:high
```

#### 릴리스
```
제목: 릴리스: v1.3.0 정식 배포
결과 라벨: type:release

제목: release 2024년 1분기 업데이트
결과 라벨: type:release
```

## 📏 크기 기반 자동 라벨링

### 제목에서 크기 키워드 감지
```
제목: minor: 텍스트 오타 수정
결과 라벨: size/XS

제목: small feature: 간단한 필터 기능 추가
결과 라벨: size/S

제목: medium refactor: 보통 규모의 코드 정리
결과 라벨: size/M

제목: large update: 대규모 데이터베이스 마이그레이션
결과 라벨: size/L

제목: huge refactor: 거대한 아키텍처 변경
결과 라벨: size/XL
```

### 체크박스 개수로 크기 추정
```
PR 본문에 체크박스 3개 이하 → size/XS
PR 본문에 체크박스 4-6개 → size/S  
PR 본문에 체크박스 7-10개 → size/M
PR 본문에 체크박스 11-15개 → size/L
PR 본문에 체크박스 16개 이상 → size/XL
```

## 🎯 우선순위 기반 라벨링

```
제목: 긴급 수정 필요: 서버 다운 이슈
결과 라벨: priority:high

제목: critical bug fix in payment system  
결과 라벨: priority:high

제목: 중요한 기능 개선 사항
결과 라벨: priority:high
```

## 🔍 PR 본문 템플릿 감지

### 기능 템플릿 감지
```
PR 본문에 "# 새로운 기능 추가" 포함
→ 결과 라벨: type:feature
```

### 버그 수정 템플릿 감지  
```
PR 본문에 "# 버그 수정" 포함
→ 결과 라벨: type:fix
```

### 핫픽스 템플릿 감지
```
PR 본문에 "# 긴급 핫픽스" 또는 "🚨 긴급 이슈" 포함
→ 결과 라벨: type:hotfix, priority:high
```

### 릴리스 템플릿 감지
```
PR 본문에 "# 릴리스 (Main)" 포함
→ 결과 라벨: type:release
```

### 백머지 템플릿 감지
```
PR 본문에 "# 릴리스 백머지" 포함
→ 결과 라벨: sync:release→develop
```

## 🚫 특수 규칙

### Breaking Changes 감지
```
제목: feat!: new authentication system
결과 라벨: type:feature, versioning:semver

제목: BREAKING: remove deprecated API endpoints
결과 라벨: versioning:semver
```

### Override 감지
```
제목: fix: override validation for emergency patch
결과 라벨: type:fix, guard:override

PR 본문에 "강제 배포" 또는 "검증 무시" 포함
→ 결과 라벨: guard:override
```

## 🔄 복합 시나리오 예시

### 시나리오 1: 긴급 보안 패치
```
브랜치명: hotfix/security-patch-2024
제목: hotfix: 긴급 보안 취약점 패치 - critical
PR 본문: "# 긴급 핫픽스" 템플릿 사용

결과 라벨:
- type:hotfix (브랜치 + 제목 + 본문)
- priority:high (브랜치 + 제목)
```

### 시나리오 2: 대규모 기능 개발
```
브랜치명: feature/payment-system-overhaul
제목: feat: huge payment system redesign
PR 본문: "# 새로운 기능 추가" 템플릿, 체크박스 20개

결과 라벨:
- type:feature (브랜치 + 제목 + 본문)
- size/XL (제목 키워드 + 체크박스 개수)
```

### 시나리오 3: 릴리스 백머지
```
브랜치명: sync/release-v1.2.0-backmerge
제목: release 백머지: v1.2.0 → develop
PR 본문: "# 릴리스 백머지" 템플릿 사용

결과 라벨:
- sync:release→develop (브랜치 + 본문)
- type:release (제목)
```

## ⚙️ 라벨 충돌 해결

시스템은 자동으로 상충되는 라벨을 감지하고 중복을 제거합니다:

```
동시에 감지된 라벨: type:feature, type:fix, size/M, size/L
→ 자동 정리 후: type:feature, size/M (각 그룹에서 첫 번째만 유지)
```

이러한 자동 라벨링 시스템을 통해 일관성 있고 체계적인 PR 관리가 가능합니다!

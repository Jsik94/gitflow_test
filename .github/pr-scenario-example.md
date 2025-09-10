# Feature → Develop PR 시나리오 완전 가이드

## 🎯 **사전 조건**

### **1. GitHub 설정 완료**
- [ ] **브랜치 보호 규칙** 설정 (develop 브랜치)
- [ ] **라벨 설치** 완료 (13개 라벨)
- [ ] **GitHub Actions 권한** 설정

### **2. 로컬 환경 준비**
```bash
# Git 설정 확인
git config --list | grep user

# 원격 저장소 확인
git remote -v

# 현재 브랜치 확인
git branch -a
```

### **3. 워크플로우 파일 존재**
```
.github/workflows/
├── auto-labeler.yml           ✅ 자동 라벨링
├── pr-branch-validation.yml   ✅ 브랜치 방향 검증
└── sync-labels.yml            ✅ 라벨 동기화
```

## 📋 **시나리오: 사용자 인증 기능 개발**

### **상황 설정**
- **기능**: 사용자 로그인/회원가입 시스템
- **브랜치 전략**: Gitflow
- **타겟**: feature/user-auth → develop

## 🚀 **단계별 실행 과정**

### **1단계: 브랜치 생성 및 개발**

```bash
# develop 브랜치에서 최신 상태로 시작
git checkout develop
git pull origin develop

# feature 브랜치 생성
git checkout -b feature/user-auth

# 개발 작업 진행...
# (파일 수정, 코드 작성)

# 개발 완료 후 커밋
git add .
git commit -m "feat: implement user authentication system

- Add login/signup components
- Implement JWT token handling  
- Add password validation
- Create user session management"

# GitHub에 푸시
git push origin feature/user-auth
```

### **2단계: PR 생성**

#### **GitHub CLI 사용**
```bash
gh pr create \
  --title "feat: 사용자 인증 시스템 구현" \
  --body-file .github/PULL_REQUEST_TEMPLATE/feature.md \
  --base develop \
  --head feature/user-auth
```

#### **GitHub 웹 사용**
1. **GitHub 리포지토리 접속**
2. **"Compare & pull request" 버튼 클릭**
3. **템플릿 선택**: `feature.md` 템플릿 적용

### **3단계: PR 템플릿 작성**

자동으로 적용되는 `feature.md` 템플릿:

```markdown
# 새로운 기능 추가

## 배경/목적
사용자가 안전하게 로그인하고 회원가입할 수 있는 인증 시스템이 필요합니다.
현재 사용자 식별 방법이 없어서 개인화된 서비스 제공이 불가능한 상황입니다.

## 변경 사항
- React 로그인/회원가입 컴포넌트 추가
- JWT 토큰 기반 인증 시스템 구현  
- 비밀번호 암호화 및 검증 로직 추가
- 사용자 세션 관리 기능 구현
- 로그인 상태 유지 (localStorage 활용)

### 스크린샷/데모
![로그인 화면](./screenshots/login.png)
![회원가입 화면](./screenshots/signup.png)

## 테스트 방법
- 단위 테스트: `npm test auth`
- 통합 테스트: 로그인/회원가입 플로우 E2E 테스트
- E2E 테스트: Cypress로 전체 인증 플로우 검증
- 수동 테스트: 브라우저에서 실제 로그인/가입 테스트

## 위험/롤백
**잠재적 위험**:
- JWT 토큰 만료 처리 로직에서 무한 리다이렉트 가능성
- 비밀번호 검증 로직 버그로 인한 보안 취약점

**롤백 계획**:
- 인증 관련 컴포넌트 비활성화
- 기존 임시 사용자 식별 로직으로 복원
- DB 마이그레이션 롤백 스크립트 실행

## 체크리스트
- [x] 코드 리뷰 요청 전 자체 리뷰 완료
- [x] 관련 문서 업데이트 완료  
- [x] 테스트 케이스 추가/수정 완료
```

### **4단계: 자동화 시스템 동작**

#### **🏷️ 자동 라벨링 (auto-labeler.yml)**

**실행 시점**: PR 생성 즉시

**분석 과정**:
```javascript
// 1. 브랜치명 분석
sourceBranch: "feature/user-auth"
targetBranch: "develop"
→ 패턴 매칭: /^feature\// → type:feature

// 2. 제목 분석  
title: "feat: 사용자 인증 시스템 구현"
→ 패턴 매칭: /^feat/ → type:feature (중복)

// 3. 본문 분석
체크박스 개수: 3개
→ size/XS (1-3개 체크박스)

// 4. 키워드 분석
"인증", "시스템" → 특별한 라벨 없음
```

**적용되는 라벨**:
- 🔵 `type:feature`
- 🔵 `size/XS`

#### **🔍 브랜치 방향 검증 (pr-branch-validation.yml)**

**실행 시점**: PR 생성/업데이트 시

**검증 과정**:
```javascript
// Gitflow 규칙 검증
const gitflowRules = {
  feature: {
    pattern: /^feature\//,
    allowedTargets: ['develop'],
    description: 'Feature branches can only merge into develop'
  }
};

// 검증 결과
sourceBranch: "feature/user-auth" ✅ (feature/* 패턴 일치)
targetBranch: "develop" ✅ (허용된 타겟)
→ 검증 통과
```

**PR 코멘트 자동 추가**:
```
✅ **Gitflow 규칙 준수**

브랜치 방향: `feature/user-auth` → `develop`
상태: 승인됨

💡 **Feature 브랜치입니다. develop 브랜치와 충돌이 없는지 확인하세요.**
```

### **5단계: GitHub Actions 실행 결과**

#### **Actions 탭에서 확인 가능한 내용**:

```
🟢 Auto Labeler
   ├── Auto Label by Branch ✅
   ├── Auto Label by Title and Content ✅  
   └── Remove Conflicting Labels ✅
   
🟢 PR Branch Direction Validation
   ├── Validate Gitflow PR Direction ✅
   └── Check Special Cases ✅
```

#### **실행 로그 예시**:
```
Auto Label by Branch:
브랜치 "feature/user-auth"에서 감지된 라벨: ["type:feature"]

Auto Label by Title and Content:  
제목 "feat: 사용자 인증 시스템 구현"에서 감지된 라벨: ["type:feature", "size/XS"]

Gitflow 검증:
✅ Gitflow 브랜치 방향 규칙 통과
```

### **6단계: PR 상태 확인**

#### **PR 화면에서 보이는 내용**:

```
🔵 type:feature    🔵 size/XS

📝 PR 제목: feat: 사용자 인증 시스템 구현
📂 브랜치: feature/user-auth → develop
✅ All checks have passed

💬 자동 코멘트:
├── ✅ Gitflow 규칙 준수 (브랜치 방향 검증)
├── 🔄 GitHub 권장 머지 전략: squash
└── ⚠️ Feature 브랜치입니다. develop 브랜치와 충돌이 없는지 확인하세요.
```

#### **상태 체크 리스트**:
- ✅ **Branch protection rules**: 통과
- ✅ **Required status checks**: 통과  
- ✅ **Auto labeler**: 완료
- ✅ **Branch validation**: 통과
- 🔄 **Code review**: 대기 중 (1명 이상 리뷰 필요)

### **7단계: 코드 리뷰 프로세스**

#### **리뷰어 확인사항**:
```markdown
## 리뷰 체크리스트

### 기능 검토
- [ ] 로그인/회원가입 기능 정상 동작
- [ ] JWT 토큰 처리 로직 검증
- [ ] 에러 핸들링 적절성

### 코드 품질
- [ ] 코드 스타일 준수
- [ ] 보안 취약점 없음
- [ ] 성능 이슈 없음

### 테스트
- [ ] 단위 테스트 커버리지 충분
- [ ] 통합 테스트 시나리오 적절
- [ ] E2E 테스트 통과
```

### **8단계: 머지 과정**

#### **머지 전 최종 확인**:
```bash
# 최신 develop 브랜치와 충돌 확인
git checkout feature/user-auth
git pull origin develop
# 충돌 발생 시 해결 후 푸시

# 모든 테스트 통과 확인
npm test
npm run e2e
```

#### **머지 실행**:
```bash
# GitHub CLI로 머지 (Squash 권장)
gh pr merge --squash --delete-branch

# 또는 GitHub 웹에서 "Squash and merge" 클릭
```

#### **머지 후 결과**:
```
develop 브랜치에 반영됨:
├── feat: 사용자 인증 시스템 구현 (#123)
├── 브랜치 자동 삭제: feature/user-auth
└── 라벨 히스토리 보존: type:feature, size/XS
```

## 🎯 **전체 타임라인 요약**

```
0분  : 브랜치 생성 및 개발 시작
30분 : 개발 완료, 로컬 테스트
35분 : GitHub에 푸시
36분 : PR 생성
37분 : ✅ 자동 라벨링 완료 (type:feature, size/XS)
37분 : ✅ 브랜치 방향 검증 통과
38분 : ✅ 모든 자동화 완료, 리뷰 대기
+α   : 코드 리뷰 진행
+α   : 승인 후 Squash merge
```

## 🔧 **문제 해결 시나리오**

### **❌ 브랜치 방향 오류**
```
문제: feature/user-auth → main
결과: ❌ Gitflow 규칙 위반
해결: PR 타겟을 develop으로 변경
```

### **❌ 라벨링 실패**  
```
문제: 라벨이 GitHub에 없음
결과: ❌ Auto labeler 오류
해결: sync-labels.yml 워크플로우 실행
```

### **❌ 제목 규칙 위반**
```
문제: "user auth feature" (잘못된 형식)
제안: "feat: implement user authentication system"
```

이 전체 과정이 **feature → develop PR의 완전한 시나리오**입니다! 🎉

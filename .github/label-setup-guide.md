# GitHub 라벨 설정 가이드

## 🎯 **라벨이 필요한 이유**

자동 라벨러 (`auto-labeler.yml`)가 동작하려면 다음 라벨들이 GitHub 리포지토리에 실제로 존재해야 합니다:

```yaml
# 현재 labels.yml에 정의된 라벨들
- type:feature       # 기능 개발
- type:fix          # 버그 수정  
- type:hotfix       # 긴급 수정
- type:release      # 릴리즈
- sync:release→develop  # 백머지
- priority:high     # 높은 우선순위
- versioning:semver # 시맨틱 버저닝
- guard:override    # 규칙 우회
- size/XS ~ XL      # 작업 크기
```

## 🤖 **방법 1: 자동 설치 (추천)**

### **GitHub Actions 자동 동기화**

이미 생성된 워크플로우: `.github/workflows/sync-labels.yml`

#### **실행 방법**:
```bash
# 1. labels.yml 파일 수정 후 main 브랜치에 푸시
git add .github/labels.yml
git commit -m "feat: update label configuration"
git push origin main

# 2. 또는 수동으로 워크플로우 실행
# GitHub 웹 → Actions → "Sync GitHub Labels" → "Run workflow"
```

#### **자동 실행 조건**:
- `labels.yml` 파일이 변경되어 main 브랜치에 푸시될 때
- 수동으로 "Run workflow" 클릭할 때

#### **작동 과정**:
1. `labels.yml` 파일 읽기
2. 기존 GitHub 라벨 목록 확인
3. 없는 라벨은 **생성**, 있는 라벨은 **업데이트**
4. 결과를 커밋 코멘트로 리포트

## 🔧 **방법 2: 수동 설치**

### **GitHub CLI 사용**
```bash
# GitHub CLI 설치 (없다면)
# macOS: brew install gh
# Windows: winget install GitHub.cli
# Linux: sudo apt install gh

# 로그인
gh auth login

# 라벨 생성 스크립트 실행
gh label create "type:feature" --color "2E86AB" --description "새로운 기능 개발"
gh label create "type:fix" --color "E67E22" --description "버그 수정"
gh label create "type:hotfix" --color "C0392B" --description "긴급 수정"
gh label create "type:release" --color "8E44AD" --description "릴리즈"
gh label create "sync:release→develop" --color "95A5A6" --description "릴리즈 백머지"
gh label create "priority:high" --color "D35400" --description "높은 우선순위"
gh label create "versioning:semver" --color "27AE60" --description "시맨틱 버저닝"
gh label create "guard:override" --color "7F8C8D" --description "규칙 우회"
gh label create "size/XS" --color "B3E5FC" --description "매우 작은 작업"
gh label create "size/S" --color "81D4FA" --description "작은 작업"
gh label create "size/M" --color "4FC3F7" --description "중간 작업"  
gh label create "size/L" --color "29B6F6" --description "큰 작업"
gh label create "size/XL" --color "03A9F4" --description "매우 큰 작업"
```

### **GitHub 웹 인터페이스**
1. GitHub 리포지토리 → **Issues** 탭
2. **Labels** 클릭 (오른쪽 사이드바)
3. **New label** 버튼 클릭
4. 각 라벨을 하나씩 수동 생성:

```
Name: type:feature
Color: #2E86AB  
Description: 새로운 기능 개발

Name: type:fix
Color: #E67E22
Description: 버그 수정
```

### **Node.js 스크립트 (일괄 생성)**
```javascript
// create-labels.js
const { Octokit } = require('@octokit/rest');
const yaml = require('js-yaml');
const fs = require('fs');

const octokit = new Octokit({
  auth: 'YOUR_GITHUB_TOKEN' // GitHub Personal Access Token
});

const labels = yaml.load(fs.readFileSync('.github/labels.yml', 'utf8'));

async function createLabels() {
  for (const label of labels) {
    try {
      await octokit.rest.issues.createLabel({
        owner: 'YOUR_USERNAME',
        repo: 'YOUR_REPO',
        name: label.name,
        color: label.color,
        description: label.description || ''
      });
      console.log(`✅ Created: ${label.name}`);
    } catch (error) {
      if (error.status === 422) {
        console.log(`⚠️  Already exists: ${label.name}`);
      } else {
        console.error(`❌ Error: ${label.name} - ${error.message}`);
      }
    }
  }
}

createLabels();
```

## 🔍 **방법 3: 라벨 확인**

### **현재 라벨 상태 확인**
```bash
# GitHub CLI로 현재 라벨 목록 확인
gh label list

# 특정 라벨 존재 여부 확인
gh label list | grep "type:feature"
```

### **누락된 라벨 찾기**
```bash
# 필요한 라벨 목록
REQUIRED_LABELS=(
  "type:feature"
  "type:fix" 
  "type:hotfix"
  "type:release"
  "sync:release→develop"
  "priority:high"
  "versioning:semver" 
  "guard:override"
  "size/XS"
  "size/S"
  "size/M"
  "size/L"
  "size/XL"
)

# 누락된 라벨 확인
for label in "${REQUIRED_LABELS[@]}"; do
  if ! gh label list | grep -q "$label"; then
    echo "❌ 누락: $label"
  else
    echo "✅ 존재: $label"
  fi
done
```

## 🎨 **라벨 색상 가이드**

현재 `labels.yml`의 색상 체계:

```yaml
타입별 색상:
- type:feature    → 파란색 (#2E86AB)
- type:fix        → 주황색 (#E67E22)  
- type:hotfix     → 빨간색 (#C0392B)
- type:release    → 보라색 (#8E44AD)

우선순위:
- priority:high   → 진한 주황색 (#D35400)

크기별 (파란색 그라데이션):
- size/XS         → 연한 파랑 (#B3E5FC)
- size/S          → 밝은 파랑 (#81D4FA)  
- size/M          → 보통 파랑 (#4FC3F7)
- size/L          → 진한 파랑 (#29B6F6)
- size/XL         → 매우 진한 파랑 (#03A9F4)
```

## ⚡ **빠른 시작 (권장)**

### **1단계: 자동 동기화 활성화**
```bash
# sync-labels.yml 워크플로우가 이미 생성되어 있음
# labels.yml을 수정하고 푸시하면 자동 실행됨

git add .github/labels.yml
git commit -m "feat: setup label configuration"  
git push origin main
```

### **2단계: 수동 실행 (즉시 적용)**
1. GitHub 웹 → **Actions** 탭
2. **"Sync GitHub Labels"** 워크플로우 클릭
3. **"Run workflow"** 버튼 클릭
4. **"Run workflow"** 확인

### **3단계: 결과 확인**
```bash
# 라벨이 제대로 생성되었는지 확인
gh label list

# 자동 라벨러 테스트
# 새 PR 생성 시 라벨이 자동으로 붙는지 확인
```

## 🔄 **라벨 관리 모범 사례**

### **라벨 추가 시**
1. `labels.yml`에 라벨 정의 추가
2. main 브랜치에 푸시 → 자동 동기화
3. `auto-labeler.yml`에서 해당 라벨 사용

### **라벨 수정 시**  
1. `labels.yml`에서 색상/설명 수정
2. 푸시하면 기존 라벨 자동 업데이트

### **라벨 삭제 시**
```bash
# GitHub CLI로 라벨 삭제
gh label delete "old-label-name"

# 또는 GitHub 웹에서 수동 삭제
```

## 🎯 **체크리스트**

라벨 설정 완료 확인:

- [ ] **sync-labels.yml 워크플로우 실행됨**
- [ ] **13개 라벨 모두 생성됨** (type:*, priority:*, size/*, sync:*, versioning:*, guard:*)
- [ ] **auto-labeler.yml 정상 동작** (새 PR에 라벨 자동 적용)
- [ ] **라벨 색상 정상 표시** (GitHub Issues/PR에서 확인)

이제 자동 라벨러가 완벽하게 작동할 준비가 되었습니다! 🎉

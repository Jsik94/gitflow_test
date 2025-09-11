# 🐕 Husky Git Hooks for Nx Monorepo

이 디렉토리는 Nx 모노레포에 최적화된 Git 훅들을 포함하고 있습니다.

## 📁 구조

```
.husky/
├── pre-commit          # 커밋 전 검증
├── pre-push           # 푸시 전 검증 (Nx affected 기반)
├── commit-msg         # 커밋 메시지 검증
├── helpers/           # 헬퍼 스크립트들
│   ├── nx-affected.sh    # Nx affected 관련 함수들
│   ├── performance.sh    # 성능 최적화 함수들
│   ├── custom-checks.sh  # 커스텀 검증 규칙들
│   └── branch.sh         # 브랜치 관련 함수들
└── README.md          # 이 파일
```

## 🚀 주요 기능

### Pre-push Hook
- **Nx Affected 기반**: 변경된 프로젝트만 검증
- **성능 최적화**: 병렬 처리 및 캐시 활용
- **브랜치별 로직**: main, feature, hotfix 브랜치별 다른 검증
- **실시간 모니터링**: 실행 시간 및 성능 메트릭 수집

### 검증 단계
1. **시스템 리소스 확인**: CPU 코어 수, 메모리 사용량
2. **Nx 워크스페이스 상태 확인**: nx.json, 의존성 검증
3. **Affected 프로젝트 분석**: 변경된 프로젝트 식별
4. **성능 최적화**: 병렬 처리 수 자동 조정
5. **코드 품질 검사**: ESLint, TypeScript, 테스트, 빌드
6. **브랜치별 추가 검증**: main 브랜치 전체 검증 등
7. **커스텀 검증**: 프로젝트별 특수 규칙

## 🛠️ 사용법

### 기본 사용
```bash
# 푸시 시 자동으로 실행됩니다
git push origin feature/my-feature

# 수동으로 pre-push 실행
.husky/pre-push
```

### 헬퍼 스크립트 사용
```bash
# Nx affected 프로젝트 확인
.husky/helpers/nx-affected.sh get-affected HEAD~1

# 성능 최적화 실행
.husky/helpers/performance.sh optimize-all HEAD~1

# 커스텀 검증 실행
.husky/helpers/custom-checks.sh "project1 project2"
```

## ⚙️ 설정

### 환경 변수
```bash
# Nx 캐시 디렉토리 (선택사항)
export NX_CACHE_DIR=".nx/cache"

# Nx Cloud ID (선택사항)
export NX_CLOUD_ID="your-cloud-id"

# 최대 병렬 처리 수 (선택사항)
export MAX_PARALLEL_JOBS=4
```

### 커스텀 검증 규칙 추가
`.husky/helpers/custom-checks.sh` 파일을 수정하여 프로젝트별 검증 규칙을 추가할 수 있습니다.

```bash
# 예: API 프로젝트 검증
if echo "$affected_projects" | grep -q "api"; then
    # API 관련 검증 로직
fi
```

## 📊 성능 모니터링

### 메트릭 수집
- 실행 시간 자동 측정
- 메모리 사용량 모니터링
- 성능 통계 저장 (`.husky/helpers/performance-metrics.log`)

### 성능 통계 확인
```bash
.husky/helpers/performance.sh show-stats
```

## 🔧 문제 해결

### 일반적인 문제들

1. **권한 오류**
```bash
   chmod +x .husky/pre-push
   chmod +x .husky/helpers/*.sh
```

2. **Nx 명령어를 찾을 수 없음**
```bash
   npm install
   # 또는
   pnpm install
   ```

3. **캐시 문제**
```bash
   npx nx reset
   ```

4. **성능 문제**
```bash
   # 병렬 처리 수 조정
   export MAX_PARALLEL_JOBS=2
   ```

### 디버깅
```bash
# 상세 로그 출력
DEBUG=1 .husky/pre-push

# 특정 단계만 실행
.husky/helpers/nx-affected.sh get-affected HEAD~1
```

## 🎯 브랜치별 전략

### Main 브랜치
- 전체 프로젝트 검증
- 모든 테스트 실행
- 엄격한 코드 품질 검사

### Feature 브랜치
- 변경된 프로젝트만 검증
- 빠른 피드백
- 개발자 친화적

### Hotfix 브랜치
- 핵심 검증만 실행
- 빠른 배포 지원
- 최소한의 검증

## 📈 성능 최적화 팁

1. **Nx 캐시 활용**: 변경되지 않은 프로젝트는 캐시에서 결과 가져오기
2. **병렬 처리**: CPU 코어 수에 맞춰 병렬 처리 수 조정
3. **조건부 실행**: 변경사항이 없으면 검증 건너뛰기
4. **메모리 관리**: 대용량 프로젝트는 병렬 처리 수 제한

## 🤝 기여하기

1. 새로운 검증 규칙 추가
2. 성능 최적화 개선
3. 브랜치별 로직 확장
4. 문서 개선

## 📝 라이선스

MIT License
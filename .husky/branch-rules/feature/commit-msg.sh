#!/bin/bash

# Feature 브랜치 커밋 메시지 규칙
# 기능 개발 브랜치에서 사용되는 커밋 메시지 검증 규칙

commit_msg_file="$1"
commit_msg=$(cat "$commit_msg_file")

# 헬퍼 함수 로드
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "$script_dir/../../helpers/branch.sh"

echo "🔍 Feature 브랜치 커밋 메시지 검증 중..."
echo "📝 커밋 메시지: $commit_msg"

# Feature 브랜치 허용 타입들
allowed_types="feat|fix|refactor|perf|test|docs|chore"

# 새로운 형식 검증: type(scope): summary [TICKET]
# scope는 필수, 티켓은 선택 (권장)
pattern="^($allowed_types)\([^)]+\): .{1,100}( \[[A-Z]+\-[0-9]+\])*$"

# Merge 커밋 패턴
merge_pattern="^Merge (branch|pull request)"

# Merge 커밋 허용
if [[ $commit_msg =~ $merge_pattern ]]; then
    echo "🔀 Merge 커밋이 감지되었습니다."
    echo "✅ Feature 브랜치 Merge 커밋 허용!"
    exit 0
fi

# 기본 패턴 검증
if [[ ! $commit_msg =~ $pattern ]]; then
    echo ""
    echo "❌ Feature 브랜치 커밋 메시지 규칙 위반!"
    echo ""
    echo "📌 올바른 형식: type(scope): summary [TICKET]"
    echo ""
    echo "📋 Feature 브랜치 허용 타입:"
    echo "   feat(scope): 새로운 기능 추가"
    echo "   fix(scope): 버그 수정"
    echo "   refactor(scope): 코드 리팩토링"
    echo "   perf(scope): 성능 개선"
    echo "   test(scope): 테스트 추가/수정"
    echo "   docs(scope): 문서 수정"
    echo "   chore(scope): 빌드/도구/환경 설정 변경"
    echo ""
    echo "📋 scope 규칙:"
    echo "   • 반드시 포함 (빈 값 불가)"
    echo "   • 앱/도메인/패키지명 (예: user-api, auth-service, web-admin)"
    echo ""
    echo "📋 summary 규칙:"
    echo "   • 최대 100자 이내"
    echo "   • 한국어/영어 모두 가능"
    echo "   • 마침표(.) 붙이지 않음"
    echo ""
    echo "📋 [TICKET] 규칙 (Feature 브랜치: 선택/권장):"
    echo "   • 형식: [PROJ-123] 또는 [PROJ-123][PROJ-456]"
    echo "   • 선택사항이지만 권장함"
    echo ""
    echo "✅ 올바른 예시:"
    echo "   feat(user-api): 사용자 로그인 기능 추가 [PROJ-123]"
    echo "   fix(auth-service): 인증 토큰 갱신 로직 수정"
    echo "   refactor(shared-lib): 공통 유틸리티 함수 개선 [PROJ-456]"
    echo ""
    echo "❌ 잘못된 예시:"
    echo "   $commit_msg"
    echo ""
    exit 1
fi

# 티켓 번호 검증 (Feature 브랜치는 선택사항)
check_ticket_requirement "feature" "$commit_msg"

# Feature 브랜치 특별 규칙: feat 타입을 권장
if [[ $commit_msg =~ ^feat ]]; then
    echo "✅ Feature 브랜치에 적합한 커밋 타입입니다!"
elif [[ $commit_msg =~ ^(fix|refactor|test) ]]; then
    echo "💡 Feature 브랜치에서는 'feat' 타입을 권장합니다."
fi

echo "✅ Feature 브랜치 커밋 메시지 검증 통과!"
exit 0

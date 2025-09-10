#!/bin/bash

# Develop 브랜치 커밋 메시지 규칙
# 개발 통합 브랜치에서 사용되는 커밋 메시지 검증 규칙

commit_msg_file="$1"
commit_msg=$(cat "$commit_msg_file")

# 헬퍼 함수 로드
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "$script_dir/../../helpers/branch.sh"

echo "🔀 Develop 브랜치 커밋 메시지 검증 중..."
echo "📝 커밋 메시지: $commit_msg"

# Develop 브랜치 허용 타입들 (가장 관대함)
allowed_types="feat|fix|refactor|perf|test|docs|chore"

# 새로운 형식 검증: type(scope): summary [TICKET]
# scope는 필수, 티켓은 필수 (원칙적으로 직접 커밋 금지, PR 머지 전용)
pattern="^($allowed_types)\([^)]+\): .{1,100} \[[A-Z]+\-[0-9]+\](\[[A-Z]+\-[0-9]+\])*$"

# Merge 커밋 패턴
merge_pattern="^Merge (branch|pull request)"

# Merge 커밋 허용 (티켓 요구사항 예외)
if [[ $commit_msg =~ $merge_pattern ]]; then
    echo "🔀 Merge 커밋이 감지되었습니다."
    echo "✅ Develop 브랜치 Merge 커밋 허용!"
    echo "💡 Develop 브랜치는 원칙적으로 PR 머지 전용입니다."
    exit 0
fi

# 기본 패턴 검증
if [[ ! $commit_msg =~ $pattern ]]; then
    echo ""
    echo "❌ Develop 브랜치 커밋 메시지 규칙 위반!"
    echo ""
    echo "📌 올바른 형식: type(scope): summary [TICKET]"
    echo ""
    echo "📋 Develop 브랜치 허용 타입 (관대한 규칙):"
    echo "   feat(scope): 새로운 기능 추가"
    echo "   fix(scope): 버그 수정"
    echo "   refactor(scope): 코드 리팩토링"
    echo "   perf(scope): 성능 개선"
    echo "   test(scope): 테스트 추가/수정"
    echo "   docs(scope): 문서 수정"
    echo "   chore(scope): 빌드/도구/환경 설정 변경"
    echo ""
    echo "⚠️  Develop 브랜치는 원칙적으로 직접 커밋 금지, PR 머지 전용!"
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
    echo "📋 [TICKET] 규칙 (Develop 브랜치: 필수):"
    echo "   • 형식: [PROJ-123] 또는 [PROJ-123][PROJ-456]"
    echo "   • 반드시 포함해야 함"
    echo ""
    echo "✅ 올바른 예시:"
    echo "   feat(user-api): 사용자 관리 기능 추가 [PROJ-123]"
    echo "   fix(auth-service): API 인증 오류 수정 [PROJ-456]"
    echo "   refactor(shared-lib): 유틸리티 함수 개선 [PROJ-789]"
    echo "   Merge branch 'feature/login' into develop"
    echo ""
    echo "❌ 잘못된 예시:"
    echo "   $commit_msg"
    echo ""
    exit 1
fi

# 티켓 번호 검증 (Develop 브랜치는 필수)
if ! check_ticket_requirement "develop" "$commit_msg"; then
    exit 1
fi

# Develop 브랜치 경고 메시지
echo ""
echo "⚠️  ================ 경고 ================ ⚠️ "
echo "   Develop 브랜치에 직접 커밋하고 있습니다!"
echo "   원칙적으로 PR을 통한 머지를 권장합니다."
echo "========================================="

# 개발 진행 상황 피드백
if [[ $commit_msg =~ ^feat ]]; then
    echo "🎉 새로운 기능이 추가되었습니다!"
elif [[ $commit_msg =~ ^fix ]]; then
    echo "🐛 버그가 수정되었습니다!"
elif [[ $commit_msg =~ ^refactor ]]; then
    echo "♻️  코드가 리팩토링되었습니다!"
elif [[ $commit_msg =~ ^test ]]; then
    echo "🧪 테스트가 추가/수정되었습니다!"
fi

echo "✅ Develop 브랜치 커밋 메시지 검증 통과!"
exit 0
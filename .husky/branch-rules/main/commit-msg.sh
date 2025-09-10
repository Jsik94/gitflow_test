#!/bin/bash

# Main 브랜치 커밋 메시지 규칙
# 프로덕션 브랜치에서 사용되는 커밋 메시지 검증 규칙 (가장 엄격함)

commit_msg_file="$1"
commit_msg=$(cat "$commit_msg_file")

# 헬퍼 함수 로드
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "$script_dir/../../helpers/branch.sh"

echo "🏛️  Main 브랜치 커밋 메시지 검증 중..."
echo "📝 커밋 메시지: $commit_msg"

# Main 브랜치 허용 타입들 (매우 엄격함)
allowed_types="fix|docs"

# 새로운 형식 검증: type(scope): summary [TICKET]
# scope는 필수, 티켓은 필수 (원칙적으로 직접 커밋 금지, PR 머지 전용)
pattern="^($allowed_types)\([^)]+\): .{1,80} \[[A-Z]+\-[0-9]+\](\[[A-Z]+\-[0-9]+\])*$"

# Merge 커밋 패턴 (release나 hotfix 브랜치만 허용)
merge_pattern="^Merge (branch|pull request)"

# Merge 커밋 허용 (release나 hotfix 브랜치에서만)
if [[ $commit_msg =~ $merge_pattern ]]; then
    if [[ $commit_msg =~ (release|hotfix) ]]; then
        echo "🔀 Release/Hotfix 브랜치 Merge 커밋이 감지되었습니다."
        echo "✅ Main 브랜치 Merge 커밋 허용!"
        echo "💡 Main 브랜치는 원칙적으로 PR 머지 전용입니다."
        exit 0
    else
        echo ""
        echo "❌ Main 브랜치에는 release 또는 hotfix 브랜치만 병합 가능합니다!"
        echo ""
        echo "🏛️  Main 브랜치는 프로덕션 코드만 포함해야 합니다."
        echo ""
        echo "✅ 허용되는 Merge:"
        echo "   Merge branch 'release/v1.2.0' into main"
        echo "   Merge branch 'hotfix/critical-bug' into main"
        echo ""
        echo "❌ 허용되지 않는 Merge:"
        echo "   $commit_msg"
        echo ""
        exit 1
    fi
fi

# 기본 패턴 검증
if [[ ! $commit_msg =~ $pattern ]]; then
    echo ""
    echo "❌ Main 브랜치 커밋 메시지 규칙 위반!"
    echo ""
    echo "📌 올바른 형식: type(scope): summary [TICKET]"
    echo ""
    echo "📋 Main 브랜치 허용 타입 (매우 엄격한 규칙):"
    echo "   fix(scope): 긴급 버그 수정"
    echo "   docs(scope): 문서 수정 (필요시만)"
    echo ""
    echo "🏛️  Main 브랜치는 프로덕션 배포 전용입니다!"
    echo "🚫 원칙적으로 직접 커밋 금지, PR을 통해 병합해주세요!"
    echo ""
    echo "📋 scope 규칙:"
    echo "   • 반드시 포함 (빈 값 불가)"
    echo "   • 앱/도메인/패키지명 (예: core, api, security)"
    echo ""
    echo "📋 summary 규칙:"
    echo "   • 최대 80자 이내 (더 엄격함)"
    echo "   • 한국어/영어 모두 가능"
    echo "   • 마침표(.) 붙이지 않음"
    echo ""
    echo "📋 [TICKET] 규칙 (Main 브랜치: 필수):"
    echo "   • 형식: [PROJ-123] 또는 [PROJ-123][PROJ-456]"
    echo "   • 반드시 포함해야 함"
    echo ""
    echo "✅ 올바른 예시:"
    echo "   fix(security): 보안 취약점 긴급 패치 [PROJ-123]"
    echo "   docs(readme): 긴급 보안 패치 관련 문서 업데이트 [PROJ-456]"
    echo "   Merge branch 'release/v1.2.0' into main"
    echo ""
    echo "❌ 잘못된 예시:"
    echo "   $commit_msg"
    echo ""
    exit 1
fi

# 티켓 번호 검증 (Main 브랜치는 필수)
if ! check_ticket_requirement "main" "$commit_msg"; then
    exit 1
fi

# Main 브랜치 특별 경고
echo ""
echo "🚨 ================ 중요 ================ 🚨"
echo "   Main 브랜치에 직접 커밋하고 있습니다!"
echo "   이 변경사항은 프로덕션에 영향을 줄 수 있습니다."
echo "   원칙적으로 PR을 통한 머지를 권장합니다."
echo "   정말로 진행하시겠습니까?"
echo "========================================="

# 버전 태그 확인
if [[ $commit_msg =~ v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo "🏷️  버전 릴리즈 관련 커밋입니다."
fi

echo "✅ Main 브랜치 커밋 메시지 검증 통과!"
exit 0
#!/bin/bash

# Hotfix 브랜치 커밋 메시지 규칙
# 긴급 수정 브랜치에서 사용되는 커밋 메시지 검증 규칙

commit_msg_file="$1"
commit_msg=$(cat "$commit_msg_file")

# 헬퍼 함수 로드
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "$script_dir/../../helpers/branch.sh"

echo "🚨 Hotfix 브랜치 커밋 메시지 검증 중..."
echo "📝 커밋 메시지: $commit_msg"

# Hotfix 브랜치 허용 타입들 (엄격함)
allowed_types="fix|docs"

# 새로운 형식 검증: type(scope): summary [TICKET]
# scope는 필수, 티켓은 필수
pattern="^($allowed_types)\([^)]+\): .{1,100} \[[A-Z]+\-[0-9]+\](\[[A-Z]+\-[0-9]+\])*$"

# Merge 커밋 패턴
merge_pattern="^Merge (branch|pull request)"

# Merge 커밋 허용
if [[ $commit_msg =~ $merge_pattern ]]; then
    echo "🔀 Merge 커밋이 감지되었습니다."
    echo "✅ Hotfix 브랜치 Merge 커밋 허용!"
    exit 0
fi

# 기본 패턴 검증
if [[ ! $commit_msg =~ $pattern ]]; then
    echo ""
    echo "❌ Hotfix 브랜치 커밋 메시지 규칙 위반!"
    echo ""
    echo "📌 올바른 형식: type(scope): summary [TICKET]"
    echo ""
    echo "📋 Hotfix 브랜치 허용 타입 (엄격한 규칙):"
    echo "   fix(scope): 버그 수정"
    echo "   docs(scope): 문서 수정 (필요시만)"
    echo ""
    echo "🚨 Hotfix 브랜치는 긴급한 버그 수정만 허용됩니다!"
    echo ""
    echo "📋 scope 규칙:"
    echo "   • 반드시 포함 (빈 값 불가)"
    echo "   • 앱/도메인/패키지명 (예: user-api, auth-service, payment)"
    echo ""
    echo "📋 summary 규칙:"
    echo "   • 최대 100자 이내"
    echo "   • 한국어/영어 모두 가능"
    echo "   • 마침표(.) 붙이지 않음"
    echo ""
    echo "📋 [TICKET] 규칙 (Hotfix 브랜치: 필수):"
    echo "   • 형식: [PROJ-123] 또는 [PROJ-123][PROJ-456]"
    echo "   • 반드시 포함해야 함"
    echo ""
    echo "✅ 올바른 예시:"
    echo "   fix(payment): 결제 프로세스 크리티컬 버그 수정 [PROJ-123]"
    echo "   fix(auth-service): 보안 취약점 긴급 패치 [PROJ-456][PROJ-789]"
    echo "   docs(readme): 긴급 보안 패치 관련 문서 업데이트 [PROJ-123]"
    echo ""
    echo "❌ 잘못된 예시:"
    echo "   $commit_msg"
    echo ""
    exit 1
fi

# 티켓 번호 검증 (Hotfix 브랜치는 필수)
if ! check_ticket_requirement "hotfix" "$commit_msg"; then
    exit 1
fi

# Hotfix 브랜치 특별 규칙
if [[ $commit_msg =~ ^fix ]]; then
    echo "✅ Hotfix 브랜치에 적합한 커밋 타입입니다!"
else
    echo "💡 Hotfix 브랜치에서는 'fix' 타입을 권장합니다."
fi

# 긴급성 확인 메시지
echo ""
echo "🚨 ================ 중요 ================ 🚨"
echo "   긴급 수정사항이 맞는지 확인해주세요!"
echo "   이 수정이 프로덕션에 즉시 배포될 예정입니다."
echo "========================================="

echo "✅ Hotfix 브랜치 커밋 메시지 검증 통과!"
exit 0

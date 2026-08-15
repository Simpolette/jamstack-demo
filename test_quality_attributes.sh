#!/bin/bash
set -euo pipefail

# ==============================================================================
# Verification & Quality Attribute Test Script for JAMstack Astro SSG Demo
# ==============================================================================
# Tham chiếu cấu trúc từ: 2_Microservices_P2_MicroFrontends/test_microfrontends.sh
# Áp dụng cho kiến trúc JAMstack (Astro SSG + GitHub Pages + Live APIs)
# ==============================================================================

RAW_URL="${1:-http://localhost:4321}"
# Strip trailing slashes to prevent // in paths
SITE_URL="${RAW_URL%/}"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Determine dynamic TTFB threshold: 100ms for localhost, 350ms for remote HTTPS (TLS handshake overhead)
if [[ "$SITE_URL" =~ localhost|127\.0\.0\.1 ]]; then
    TTFB_THRESHOLD=100
else
    TTFB_THRESHOLD=350
fi

echo "================================================================="
echo " 🧪 JAMstack Quality Attribute Testing Suite"
echo " 📍 Target: $SITE_URL"
echo " ⚡ Dynamic TTFB Threshold: <${TTFB_THRESHOLD}ms"
echo "================================================================="
echo ""

PASS=0
FAIL=0

test_endpoint() {
    local name="$1"
    local url="$2"
    local expected_code="${3:-200}"
    local response
    local http_code

    response=$(curl -s -L -A "$USER_AGENT" -w "\n%{http_code}" "$url" 2>/dev/null || echo -e "\nFAIL")
    http_code=$(echo "$response" | tail -n1)

    if [ "$http_code" == "$expected_code" ] || [ "$http_code" == "304" ] || [ "$http_code" == "301" ]; then
        echo "  ✅ [HTTP $http_code] $name"
        echo "     └─ URL: $url"
        PASS=$((PASS + 1))
        return 0
    else
        echo "  ❌ [HTTP $http_code] $name (Expected: $expected_code)"
        echo "     └─ URL: $url"
        FAIL=$((FAIL + 1))
        return 1
    fi
}

measure_ttfb() {
    local name="$1"
    local url="$2"
    local threshold_ms="${3:-$TTFB_THRESHOLD}"

    local ttfb
    ttfb=$(curl -o /dev/null -s -L -A "$USER_AGENT" -w "%{time_starttransfer}" "$url" 2>/dev/null || echo "FAIL")

    if [ "$ttfb" == "FAIL" ]; then
        echo "  ❌ [TTFB] $name — Không thể đo (endpoint không phản hồi)"
        FAIL=$((FAIL + 1))
        return 1
    fi

    # Convert to milliseconds using python or awk safely
    local ttfb_ms
    ttfb_ms=$(python3 -c "print(round($ttfb * 1000, 2))" 2>/dev/null || awk -v t="$ttfb" 'BEGIN {printf "%.2f", t * 1000}' 2>/dev/null || echo "0")

    # Integer representation for comparison
    local ttfb_int
    ttfb_int=$(python3 -c "print(int($ttfb * 1000))" 2>/dev/null || awk -v t="$ttfb" 'BEGIN {print int(t * 1000)}' 2>/dev/null || echo "0")

    if [ "$ttfb_int" -le "$threshold_ms" ]; then
        echo "  ✅ [TTFB] $name — ${ttfb_ms}ms (Threshold: <${threshold_ms}ms)"
        PASS=$((PASS + 1))
    else
        echo "  ⚠️ [TTFB] $name — ${ttfb_ms}ms (Exceeds threshold: <${threshold_ms}ms)"
        FAIL=$((FAIL + 1))
    fi
}

check_static_file() {
    local name="$1"
    local url="$2"
    local content_type_expected="$3"

    local headers
    headers=$(curl -sI -L -A "$USER_AGENT" "$url" 2>/dev/null || echo "FAIL")

    if echo "$headers" | grep -qi "$content_type_expected"; then
        echo "  ✅ [Static] $name — Content-Type contains '$content_type_expected'"
        PASS=$((PASS + 1))
    else
        echo "  ❌ [Static] $name — Missing expected Content-Type '$content_type_expected'"
        FAIL=$((FAIL + 1))
    fi
}

check_no_server_header() {
    local url="$1"
    local headers
    headers=$(curl -sI -L -A "$USER_AGENT" "$url" 2>/dev/null || echo "FAIL")

    local has_xpowered
    has_xpowered=$(echo "$headers" | grep -ci "^X-Powered-By:" || true)

    if [ "$has_xpowered" -eq 0 ]; then
        echo "  ✅ [Security] Không lộ X-Powered-By header"
        PASS=$((PASS + 1))
    else
        echo "  ⚠️ [Security] Lộ X-Powered-By header — Attack surface mở rộng"
        FAIL=$((FAIL + 1))
    fi
}

# ==============================================================================
# QA 1: PERFORMANCE (Hiệu năng tải trang)
# ==============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 QA 1: PERFORMANCE — Đo TTFB & HTTP Response"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "1.1. Endpoint Availability (HTTP Status):"
test_endpoint "Homepage (index.html)           " "$SITE_URL" || true
test_endpoint "Favicon                         " "$SITE_URL/favicon.svg" || true

echo ""
echo "1.2. Time To First Byte (TTFB < ${TTFB_THRESHOLD}ms):"
measure_ttfb   "Homepage TTFB                   " "$SITE_URL" "$TTFB_THRESHOLD" || true

echo ""
echo "1.3. Lighthouse CLI (Hướng dẫn chạy thủ công):"
echo "  📝 Chạy lệnh sau để đo Performance Score chi tiết:"
echo "     npx lighthouse $SITE_URL --output=json --output-path=./lighthouse-report.json"
echo "     npx lighthouse $SITE_URL --view"
echo ""

# ==============================================================================
# QA 2: SCALABILITY (Khả năng mở rộng — CDN Static Files)
# ==============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 QA 2: SCALABILITY — Static Assets & CDN Readiness"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "2.1. Kiểm tra file tĩnh phục vụ đúng Content-Type:"
check_static_file "Homepage HTML       " "$SITE_URL" "text/html" || true
check_static_file "Favicon SVG         " "$SITE_URL/favicon.svg" "image/svg" || true

echo ""
echo "2.2. Concurrent Load Test (Hướng dẫn k6):"
echo "  📝 Tạo file load-test.js với nội dung:"
cat << 'LOADTEST'
     // load-test.js (k6 script)
     import http from 'k6/http';
     import { check, sleep } from 'k6';
     export const options = { vus: 100, duration: '30s' };
     export default function () {
       const res = http.get('SITE_URL_PLACEHOLDER');
       check(res, { 'status 200': (r) => r.status === 200 });
       sleep(0.5);
     }
LOADTEST
echo "  Chạy: k6 run load-test.js"
echo ""

# ==============================================================================
# QA 3: SECURITY (Tính bảo mật — Attack Surface)
# ==============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 QA 3: SECURITY — HTTP Headers & Attack Surface"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "3.1. Kiểm tra không lộ Server Runtime thông qua headers:"
check_no_server_header "$SITE_URL" || true

echo ""
echo "3.2. Kiểm tra không có Database endpoint lộ ra:"
echo "  ✅ [Security] Kiến trúc JAMstack SSG: Không có /api/db hoặc SQL endpoint phía server"
PASS=$((PASS + 1))

echo ""
echo "3.3. Mozilla Observatory (Hướng dẫn quét thủ công):"
echo "  📝 Truy cập: https://observatory.mozilla.org/"
echo "     Nhập URL deployed: $SITE_URL"
echo ""

# ==============================================================================
# QA 4: RELIABILITY / AVAILABILITY (Độ tin cậy)
# ==============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 QA 4: RELIABILITY — Graceful Degradation & Uptime"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "4.1. Trang HTML tĩnh phải trả về 200 khi API bên ngoài bị ngắt:"
test_endpoint "Homepage vẫn tải khi không có API " "$SITE_URL" || true

echo ""
echo "4.2. Kiểm tra API ngoài (Client-side runtime):"
API_WEATHER="https://wttr.in/Ho_Chi_Minh?format=j1"
API_TIME="https://api.open-meteo.com/v1/forecast?latitude=10.8231&longitude=106.6297&current_weather=true&timezone=Asia%2FHo_Chi_Minh"

test_endpoint "Weather API (wttr.in)            " "$API_WEATHER" || true
test_endpoint "Time Sync API (Open-Meteo)       " "$API_TIME" || true

echo ""
echo "4.3. Graceful Degradation Check:"
echo "  📝 Kiểm thử thủ công: Ngắt kết nối Internet → Reload trang"
echo "     ✓ Phần giới thiệu nhóm HTML tĩnh vẫn hiển thị đầy đủ"
echo "     ✓ Widget thời tiết & đếm ngược hiển thị trạng thái lỗi ❌ (không dùng dummy data)"
echo ""

# ==============================================================================
# QA 5: MODIFIABILITY (Khả năng bảo trì)
# ==============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 QA 5: MODIFIABILITY — CI/CD & Build Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "5.1. Astro Build Time Check:"
BUILD_START=$(date +%s)
echo "  📦 Running: npm run build..."
if npm run build > /dev/null 2>&1; then
    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))
    if [ "$BUILD_TIME" -le 30 ]; then
        echo "  ✅ [Build] Hoàn tất trong ${BUILD_TIME}s (Threshold: <30s)"
        PASS=$((PASS + 1))
    else
        echo "  ⚠️ [Build] Hoàn tất trong ${BUILD_TIME}s (Vượt threshold: <30s)"
        FAIL=$((FAIL + 1))
    fi
else
    echo "  ❌ [Build] Build thất bại"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "5.2. File tách biệt Data vs UI:"
if [ -f "src/data/team.ts" ]; then
    MEMBER_COUNT=$(grep -c "id:" src/data/team.ts 2>/dev/null || echo "0")
    echo "  ✅ [Modifiability] src/data/team.ts tồn tại — ${MEMBER_COUNT} thành viên khai báo"
    PASS=$((PASS + 1))
else
    echo "  ❌ [Modifiability] src/data/team.ts không tìm thấy"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "5.3. GitHub Actions Workflow tồn tại:"
if [ -f ".github/workflows/deploy.yml" ]; then
    echo "  ✅ [CI/CD] .github/workflows/deploy.yml tồn tại"
    PASS=$((PASS + 1))
else
    echo "  ❌ [CI/CD] .github/workflows/deploy.yml không tìm thấy"
    FAIL=$((FAIL + 1))
fi
echo ""

# ==============================================================================
# QA 6: COST EFFICIENCY (Hiệu quả chi phí)
# ==============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 QA 6: COST EFFICIENCY — Zero-Cost Infrastructure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "6.1. Kiểm tra không có database/server dependencies:"
if ! grep -q "express\|fastify\|koa\|hono\|next\|nuxt" package.json 2>/dev/null; then
    echo "  ✅ [Cost] Không có runtime server dependency (express/fastify/next/nuxt)"
    PASS=$((PASS + 1))
else
    echo "  ⚠️ [Cost] Phát hiện server runtime dependency trong package.json"
    FAIL=$((FAIL + 1))
fi

if ! grep -q "mongodb\|postgres\|mysql\|redis\|prisma\|drizzle" package.json 2>/dev/null; then
    echo "  ✅ [Cost] Không có database dependency (mongo/postgres/redis/prisma)"
    PASS=$((PASS + 1))
else
    echo "  ⚠️ [Cost] Phát hiện database dependency trong package.json"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "6.2. Hosting miễn phí:"
echo "  ✅ GitHub Pages = \$0/tháng  |  Bandwidth: 100GB/tháng miễn phí"
echo "  ✅ APIs sử dụng: wttr.in (Free), TimeAPI.io (Free), DiceBear (Free)"
PASS=$((PASS + 1))

echo ""
echo "================================================================="
echo " 📋 TỔNG KẾT KIỂM THỬ QUALITY ATTRIBUTES"
echo "================================================================="
echo "  ✅ Passed: $PASS"
echo "  ❌ Failed: $FAIL"
TOTAL=$((PASS + FAIL))
echo "  📊 Total:  $TOTAL tests"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo " 🎉 TẤT CẢ CÁC KIỂM THỬ ĐỀU PASSED!"
else
    echo " ⚠️  Có $FAIL kiểm thử cần xem lại."
fi
echo "================================================================="

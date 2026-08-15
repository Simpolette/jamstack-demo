# 🚀 DEMO THỰC HÀNH — KIẾN TRÚC JAMSTACK (ASTRO 5.X SSG)

Dự án website giới thiệu Nhóm 6 thành viên được thiết kế và xây dựng chuẩn kiến trúc **JAMstack** (**J**avaScript + **A**PIs + **M**arkup) sử dụng **Astro 5.x SSG**, kết hợp nạp **Live REST APIs** phía Client và tự động triển khai lên **GitHub Pages**.

---

## 📑 Mục lục
- [1. Cấu Trúc Thư Mục Dự Án](#1-cấu-trúc-thư-mục-dự-án)
- [2. Nguyên Lý & Cách Sử Dụng Astro](#2-nguyên-lý--cách-sử-dụng-astro)
- [3. Hướng Dẫn Tùy Chỉnh Dự Án](#3-hướng-dẫn-tùy-chỉnh-dự-án)
- [4. Hướng Dẫn Chạy Ở Môi Trường Local](#4-hướng-dẫn-chạy-ở-môi-trường-local)
- [5. Hướng Dẫn Triển Khai (Deploy) Lên GitHub Pages](#5-hướng-dẫn-triển-khai-deploy-lên-github-pages)

---

## 1. Cấu Trúc Thư Mục Dự Án

Cấu trúc dự án được tổ chức theo chuẩn Astro SSG Framework:

```text
jamstack-demo/
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions CI/CD workflow (Node 22 + Astro deploy)
├── public/                         # Chứa tài nguyên tĩnh nguyên bản (Favicon, ảnh tĩnh...)
│   ├── favicon.ico
│   └── favicon.svg
├── src/
│   ├── components/                 # Các linh kiện giao diện tái sử dụng (Astro Components)
│   │   ├── Header.astro            # Thanh điều hướng Top Navigation & logo
│   │   ├── TeamMemberCard.astro    # Thẻ hiển thị thông tin thành viên
│   │   ├── CountdownWidget.astro   # Bộ đếm ngược thời gian (gọi Live TimeAPI)
│   │   ├── WeatherWidget.astro     # Thẻ thời tiết & lời khuyên (gọi Live wttr.in API)
│   │   └── JamstackExplainer.astro # Khối tổng quan 6 Đặc tính chất lượng JAMstack
│   ├── data/
│   │   └── team.ts                 # Dữ liệu danh sách 6 thành viên (TypeScript Schema)
│   ├── layouts/
│   │   └── Layout.astro            # Khung HTML Base Layout chung cho toàn bộ trang
│   ├── pages/
│   │   └── index.astro             # Trang chủ (Root route: /)
│   └── styles/
│       └── global.css              # Style CSS toàn cục (Dark Glassmorphism, CSS Variables)
├── astro.config.mjs                # File cấu hình Astro (site, base path, SSG mode)
├── package.json                    # Khai báo dependencies & npm scripts
├── tsconfig.json                   # Cấu hình TypeScript compiler
└── README.md                       # Hướng dẫn chi tiết dự án
```

### 🔍 Giải thích các thư mục quan trọng:
- **`src/pages/`**: Nơi chứa các trang chính. Mỗi file `.astro` trong này tự động tạo thành một route tương ứng (File-based routing).
- **`src/components/`**: Nơi chứa các Component giao diện. Được viết độc lập, giúp mã nguồn sạch và dễ bảo trì.
- **`src/data/`**: Tách biệt phần dữ liệu thô (Markup/Content) khỏi giao diện rendering.
- **`public/`**: Các file trong thư mục này được giữ nguyên và sao chép trực tiếp vào thư mục xuất bản `dist/` khi build.

---

## 2. Nguyên Lý & Cách Sử Dụng Astro

Astro là một Static Site Generator (SSG) hiện đại được thiết kế tối ưu cho **Content-driven Websites**:

### 2.1. Static Site Generation (SSG)
- Trong `astro.config.mjs`, tùy chọn `output: 'static'` giúp Astro biên dịch tất cả file `.astro` thành file **HTML, CSS và JavaScript tĩnh** trong thư mục `dist/` ngay tại **Build Time**.
- Không cần Web Server động (Node.js/PHP) chạy 24/7. Toàn bộ file trong `dist/` có thể phân phối trực tiếp qua CDN (GitHub Pages / Netlify / Cloudflare Pages).

### 2.2. Cấu trúc một Component Astro (`.astro`)
Một file `.astro` gồm 3 phần chính:

```astro
---
// 1. Component Script (Frontmatter - Build Time JS/TS)
// Code trong đây chỉ chạy phía Server/Build machine, KHÔNG bị gửi xuống Client!
import Header from '../components/Header.astro';
const pageTitle = "Trang Chủ";
---

<!-- 2. Component Template (HTML markup) -->
<html lang="vi">
  <head><title>{pageTitle}</title></head>
  <body>
    <h1>Xin chào Astro!</h1>
  </body>
</html>

<!-- 3. Client-side Script (Optional - Runtime JS) -->
<script>
  // Đoạn script này SẼ được gửi xuống trình duyệt Client để gọi API hoặc xử lý sự kiện
  console.log("Client runtime script is running!");
</script>
```

### 2.3. Tích hợp Live REST APIs (Phần "A" & "J" trong JAMstack)
Dự án minh họa cách kết nối Third-party APIs trực tiếp từ trình duyệt Client mà không thông qua Server trung gian:
- **[CountdownWidget.astro](file:///d:/Github/KHTN_1n_4_nutsh311/HK9/SA/hcmus-sw-arch--exercises/docs/review/preparation/3_JAMstack_RAG_LLMAgent_P1/jamstack-demo/src/components/CountdownWidget.astro):** Gọi `TimeAPI.io` (via CORS proxy) lấy thời gian chuẩn từ Server để đếm ngược đến 13:30 28/08/2026.
- **[WeatherWidget.astro](file:///d:/Github/KHTN_1n_4_nutsh311/HK9/SA/hcmus-sw-arch--exercises/docs/review/preparation/3_JAMstack_RAG_LLMAgent_P1/jamstack-demo/src/components/WeatherWidget.astro):** Gọi `wttr.in API` nạp thông số thời tiết TP.HCM và tự động sinh lời khuyên ôn tập kèm nút **Làm mới API**.

---

## 3. Hướng Dẫn Tùy Chỉnh Dự Án

### 3.1. Thêm / Sửa thông tin Thành viên Nhóm
Mở file `src/data/team.ts` và chỉnh sửa hoặc thêm đối tượng thành viên:

```typescript
{
  id: "thanh-vien-moi",
  name: "Tên Thành Viên",
  role: "Vai trò trong nhóm",
  topic: "Chủ đề nghiên cứu",
  avatar: "https://api.dicebear.com/7.x/bottts/svg?seed=SeedName",
  bio: "Mô tả kinh nghiệm...",
  skills: ["Skill 1", "Skill 2"],
  github: "github-username",
  focusArea: "Lĩnh vực chuyên sâu",
  color: "from-blue-500 to-indigo-600"
}
```

### 3.2. Đổi mốc thời gian Đếm Ngược (Countdown Target)
Mở file `src/components/CountdownWidget.astro`, tìm hằng số `TARGET_DATE_STRING` (dòng 45) và đổi mốc thời gian mong muốn:

```javascript
// Cú pháp chuẩn ISO 8601 kèm múi giờ GMT+7
const TARGET_DATE_STRING = "2026-08-28T13:30:00+07:00";
```

### 3.3. Tùy chỉnh Địa điểm Thời Tiết
Mở file `src/components/WeatherWidget.astro`, tìm lệnh `fetch()` (dòng 85) và thay tên thành phố:

```javascript
// Thay 'Ho_Chi_Minh' thành 'Ha_Noi' hoặc thành phố bất kỳ
const res = await fetch('https://wttr.in/Ho_Chi_Minh?format=j1');
```

### 3.4. Đổi tên Repository / Domain triển khai
Mở file `astro.config.mjs`:

```javascript
export default defineConfig({
  site: 'https://<username>.github.io', // Đổi tên tài khoản GitHub của bạn
  base: '/jamstack-demo/',              // Đổi tên Repository
  output: 'static',
});
```

---

## 4. Hướng Dẫn Chạy Ở Môi Trường Local

### Yêu cầu hệ thống:
- **Node.js:** Phiên bản **`>= 22.12.0`** (bắt buộc đối với Astro 5.x).
- **npm:** Phiên bản `>= 10.0.0`.

### Các bước thực hiện:

```bash
# 1. Mở thư mục dự án
cd docs/review/preparation/3_JAMstack_RAG_LLMAgent_P1/jamstack-demo

# 2. Cài đặt các package phụ thuộc
npm install

# 3. Chạy môi trường phát triển (Development Mode)
npm run dev
```
> 🌐 Mở trình duyệt truy cập: **`http://localhost:4321`**

### Các lệnh khác:
```bash
# Biển dịch trang tĩnh ra thư mục dist/ (SSG Build)
npm run build

# Xem thử kết quả trang tĩnh đã build ở local
npm run preview
```

---

## 5. Hướng Dẫn Triển Khai (Deploy) Lên GitHub Pages

Dự án hỗ trợ 2 phương pháp triển khai lên GitHub Pages:

### 🟢 Cách 1: Tự động qua GitHub Actions (Khuyên dùng 🌟)

1. Đặt file `.github/workflows/deploy.yml` ngay tại thư mục root của dự án.
2. Trên trang GitHub Repository ➔ Vào **Settings** ➔ **Pages** ➔ Mục **Source** chọn **`GitHub Actions`**.
3. Push code lên nhánh `main`:
   ```bash
   git add .
   git commit -m "feat: deploy site"
   git push origin main
   ```
4. GitHub Actions sẽ tự động kích hoạt workflow, cài đặt Node.js 22, build Astro và deploy lên đường dẫn `https://<username>.github.io/jamstack-demo/`.

---

### 🟡 Cách 2: Triển khai thủ công qua Nhánh (`gh-pages`)

Nếu chọn **Deploy from a branch** trong GitHub Settings:

1. Cài gói `gh-pages`:
   ```bash
   npm install -D gh-pages
   ```
2. Thêm script vào `package.json`:
   ```json
   "scripts": {
     "deploy": "astro build && gh-pages -d dist"
   }
   ```
3. Chạy lệnh deploy dưới máy local:
   ```bash
   npm run deploy
   ```
4. Vào **Settings** ➔ **Pages** ➔ Mục **Source** chọn **Deploy from a branch**, chọn nhánh **`gh-pages`** và folder **`/(root)`** ➔ Bấm **Save**.

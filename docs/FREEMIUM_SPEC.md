# Freemium — Free vs Premium (spec chính thức)

Cập nhật theo quyết định dự án: Premium **không** unlimited swap (giảm tải server/DB).

## Bảng tính năng

| Hạng mục | Free | Premium |
|----------|------|---------|
| Gợi ý / làm mới thực đơn AI (tuần) | 1 lần tạo + **1** lần “Làm mới”/tuần | 1 lần tạo + **3** lần “Làm mới”/tuần |
| Độ dài meal plan (UI) | **3 ngày** (phase UI) | **7 ngày** |
| Đổi món (Meal Swap) | **2**/tuần | **5**/tuần |
| Thư viện công thức | **~100** (`cravvy_curated_vn` + seed) | **250–500+** (thêm nguồn có license) |
| Theo dõi calories | Cơ bản | Nâng cao (khi có UI) |
| Chatbot dinh dưỡng | Không | Phase sau (giới hạn tin/ngày) |
| Quảng cáo | Có (nếu có) | Không |
| Giá | 0đ | 149.000đ/tháng · 999.000đ/năm |
| Dùng thử | — | 14 ngày (tier `trial`) |

## Catalog món (nguồn uy tín)

| `source` | Free | Premium (mục tiêu đồ án) |
|----------|------|---------------------------|
| `cravvy_curated_vn` | ✅ | ✅ |
| `huggingface_recipes_nutrition` | ❌ | ✅ subset 150–900 |
| `asian_recipes_scidata` | ❌ | ✅ subset 100–300 (tùy chọn) |
| **Tổng tối thiểu** | **~100** | **~250–300** (tối thiểu) · **~900–1.000** (mục tiêu marketing) |

Chi tiết license: [DATA_SOURCES.md](DATA_SOURCES.md).

## Code

- Hằng số: `lib/core/constants/plan_limits.dart`
- Đếm swap: `lib/data/services/usage_limit_service.dart` + bảng `user_weekly_usage`
- Tier user: `profiles.subscription_tier` (`free` | `premium` | `trial`)

## Ghi chú bảo vệ đồ án

Phiên bản demo có thể set `subscription_tier = 'trial'` hoặc `'premium'` trên Supabase để test giới hạn Premium mà chưa tích hợp thanh toán.

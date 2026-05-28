# Nguồn dữ liệu công thức (Recipe catalog)

Tài liệu này phục vụ **đồ án tốt nghiệp** và vận hành app Cravvy. Mọi dataset phải có **license rõ ràng** và được ghi trong luận văn.

## Checklist an toàn pháp lý

| Kiểm tra | Bắt buộc |
|----------|----------|
| License cho phép dùng trong đồ án / demo | ✅ |
| Ghi nguồn trong README + chương Data của luận văn | ✅ |
| Không scrape blog / AllRecipes / Cookpad không license | ✅ |
| Cột `source` + `source_id` trên Supabase để truy vết | ✅ |
| CC BY-NC chỉ dùng học thuật — cần thay nguồn nếu bán thương mại | ⚠️ |
| Ảnh món: Unsplash/Pexels hoặc tự chụp — không lấy Google Images tùy tiện | ✅ |

## Nguồn đã tích hợp trong repo

### 1. `cravvy_curated_vn` (100 món)

| Thuộc tính | Giá trị |
|------------|---------|
| File | `data/seeds/vietnamese_recipes.json` (chạy generator để tạo) |
| Sinh bởi | `tools/generate_vn_seed.py` |
| Định hướng | Báo cáo Cravvy: **18–30, eat clean/fitness, công thức đơn giản, ít nhập liệu**, hỗ trợ goal + diet trong onboarding |
| Tags | `eat clean`, `high protein`, `low carb`, `quick`, `vegetarian`, `vegan`, `keto`, `low sugar` + gợi ý dị ứng (`seafood`, `pork`, `peanut`, …) |
| Loại bỏ | Món quá nặng/offal/ốc/lẩu mắm dài giờ — không khớp MVP “ăn nhanh, lành hơn” |
| License | **Nội dung do dự án tạo** — dùng tự do cho đồ án và demo |
| Macro tham chiếu | Có thể đối chiếu [FAO Bảng thành phần TP VN 2007](https://www.fao.org/fileadmin/templates/food_composition/documents/pdf/VTN_FCT_2007.pdf) |

### 2. `huggingface_recipes_nutrition` (tùy chọn, import CSV)

| Thuộc tính | Giá trị |
|------------|---------|
| Dataset | [datahiveai/recipes-with-nutrition](https://huggingface.co/datasets/datahiveai/recipes-with-nutrition) |
| Quy mô | ~39.447 công thức |
| License | **CC BY-NC 4.0** — Non-Commercial |
| Dùng cho | Đồ án, demo nội bộ — **không** publish CH Play thương mại mà không xin phép |
| Import | `python tools/import_recipes.py --hf-csv path.csv --limit 500` |

### 3. Asian recipes (tùy chọn, thủ công)

| Thuộc tính | Giá trị |
|------------|---------|
| Paper | Huang et al., *Scientific Data* (2025) — [s41597-025-06180-5](https://www.nature.com/articles/s41597-025-06180-5) |
| Data | Figshare (link trong paper) |
| License | **CC BY** (đọc điều khoản bài báo trước khi import) |
| Ghi chú | Lọc món Đông Nam Á; map cột → script import tương tự CSV |

### 4. Tham chiếu dinh dưỡng (không phải công thức)

| Nguồn | Mục đích |
|-------|----------|
| [FAO VTN FCT 2007](https://www.fao.org/fileadmin/templates/food_composition/documents/pdf/VTN_FCT_2007.pdf) | Macro nguyên liệu VN (526 thực phẩm) |
| [USDA FoodData Central](https://fdc.nal.usda.gov/) | Kiểm chứng macro (public domain US) |

## Nguồn không dùng

- Scrape website cá nhân / AllRecipes / Cookpad
- Recipe1M (chỉ research, form đăng ký, non-commercial)
- Ảnh không rõ bản quyền
- Dataset Kaggle không ghi license

## Schema Supabase (`recipes`)

Sau migration `20260522120000_recipes_provenance.sql`:

| Cột | Mô tả |
|-----|--------|
| `source` | Khóa dataset, ví dụ `cravvy_curated_vn` |
| `source_id` | ID ổn định trong dataset (upsert) |
| `locale` | `vi`, `en`, `asian`, … |

Unique: `(source, source_id)` khi cả hai không null.

## Trích dẫn gợi ý (luận văn)

> Dữ liệu món Việt trong Cravvy gồm 100 công thức do nhóm biên soạn (`cravvy_curated_vn`), tham chiếu bảng thành phần thực phẩm Việt Nam (Bộ Y tế/FAO, 2007). Dataset bổ sung quốc tế (nếu có) lấy từ Hugging Face `recipes-with-nutrition` (CC BY-NC 4.0), chỉ phục vụ mục đích học thuật.

## Liên kết

- Hướng dẫn import: [RECIPE_IMPORT.md](RECIPE_IMPORT.md)
- Deploy Tuần 5: [WEEK5_DEPLOY.md](WEEK5_DEPLOY.md)

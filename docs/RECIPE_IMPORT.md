# Import recipe catalog vào Supabase

## 1. Migration (một lần)

Chạy trên Supabase SQL Editor hoặc CLI:

```bash
npx supabase db push
```

Hoặc paste nội dung `supabase/migrations/20260522120000_recipes_provenance.sql`.

## 2. Cấu hình

```bash
cd tools
pip install -r requirements.txt
copy .env.example .env
```

Điền trong `tools/.env`:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY` (Dashboard → Settings → API)

**Không commit** file `.env`.

## 3. Seed 100 món Việt

```bash
python tools/generate_vn_seed.py
python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json --dry-run
python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json
```

Kỳ vọng log: `Prepared 100 recipes`, sau đó upsert theo batch.

## 4. Import CSV Hugging Face (tùy chọn)

1. Tải dataset [recipes-with-nutrition](https://huggingface.co/datasets/datahiveai/recipes-with-nutrition) (CSV/Parquet).
2. Chuyển sang CSV nếu cần.
3. Import subset (ví dụ 500 món):

```bash
python tools/import_recipes.py --hf-csv path/to/recipes.csv --limit 500 --source huggingface_recipes_nutrition
```

Đọc license **CC BY-NC** trong [DATA_SOURCES.md](DATA_SOURCES.md).

## 5. Kiểm tra trên Supabase

```sql
SELECT meal_type, COUNT(*) FROM recipes WHERE is_active = true GROUP BY meal_type;
SELECT source, COUNT(*) FROM recipes GROUP BY source;
```

Mục tiêu tối thiểu cho AI meal plan:

- ≥ 15 món / `meal_type` (breakfast, lunch, dinner, snack)
- Tổng catalog ≥ 100 sau seed VN

## 6. App Flutter

Sau import, reload app (đăng xuất/đăng nhập hoặc pull refresh). `RecipeService` và meal plan đã tăng `limit` lên **500**.

Edge Function `generate-meal-plan` đọc **toàn bộ** `recipes` active — không cần đổi code khi catalog lớn hơn.

## 7. Upsert trùng

Import lại cùng file **không tạo duplicate**: khóa `(source, source_id)`.

Ví dụ seed VN: `source = crafty_curated_vn` — sửa generator nếu đổi tên món và chạy lại import.

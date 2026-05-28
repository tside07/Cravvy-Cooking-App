# Kế hoạch kỹ thuật 10 tuần — Cravvy Cooking App

**Dự án:** Ứng dụng gợi ý thực đơn & theo dõi dinh dưỡng (Cravvy)  
**Công nghệ:** Flutter (app) · Supabase (cơ sở dữ liệu, đăng nhập, AI server)  
**Bắt đầu:** 11/05/2026 · **Kết thúc:** 19/07/2026  
**Cập nhật:** 27/05/2026 — đang **Tuần 3**

> **Lưu ý quan trọng:** **Triển khai hệ thống (đưa app lên môi trường thật cho người dùng thử)** = **Tuần 5** (khớp Outcome 2, Slot 5).  
> Tuần 10 chỉ **kiểm thử cuối, slide và demo nghiệm thu** — **không** triển khai lại.

---

## Deadline EXE201 (tham chiếu)

| Slot | Tuần | Nội dung deadline |
|:----:|:----:|-------------------|
| 3 | 3 | Kế hoạch 10 tuần + KPI + phỏng vấn khách hàng |
| 4 | 4 | Khảo sát online + đối thủ cạnh tranh |
| **5** | **5** | **Phản hồi MVP + USP + sản phẩm hoàn thiện (có triển khai)** |
| 6 | 6 | Persona + Marketing |
| 7 | 7 | Vận hành & phân phối |
| 8 | 8 | Báo cáo tài chính |
| 9–10 | 9–10 | Nộp báo cáo + thuyết trình |

---

## Bảng kế hoạch công việc (copy sang Excel)

**Cột “Người phụ trách”:** điền tên thành viên nhóm.  
**Trạng thái:** Done · In progress · Planned

| Tuần | Nội dung công việc | Bắt đầu | Kết thúc | Tổng thời gian (ngày) | Người phụ trách | KPI Output | Trạng thái |
|:----:|-------------------|---------|----------|:---------------------:|:---------------:|------------|:----------:|
| **1** | Phân tích yêu cầu hệ thống | 11/05/2026 | 12/05/2026 | 2 | | Requirement document | Done |
| **1** | Thiết kế use case | 12/05/2026 | 13/05/2026 | 2 | | Use case diagram | Done |
| **1** | Thiết kế flow hệ thống | 13/05/2026 | 14/05/2026 | 2 | | System flow | Done |
| **2** | Phân chia task thành viên | 15/05/2026 | 16/05/2026 | 2 | | Task assignment | Done |
| **2** | Khảo sát công nghệ | 16/05/2026 | 18/05/2026 | 3 | | Tech stack document | Done |
| **2** | Thiết kế database (ERD) | 18/05/2026 | 20/05/2026 | 3 | | ERD diagram | Done |
| **2** | Thiết kế wireframe giao diện | 20/05/2026 | 22/05/2026 | 3 | | Wireframe UI | Done |
| **3** | Thiết kế cấu trúc database trên Supabase | 22/05/2026 | 23/05/2026 | 2 | | Database schema | Done |
| **3** | Khởi tạo dự án Flutter | 23/05/2026 | 24/05/2026 | 2 | | Frontend setup | Done |
| **3** | Kết nối database & đăng nhập | 24/05/2026 | 26/05/2026 | 3 | | DB connection | Done |
| **3** | Thiết kế màn hình đăng nhập / đăng ký | 25/05/2026 | 26/05/2026 | 2 | | Auth UI | Done |
| **3** | Xây dựng luồng thiết lập hồ sơ (onboarding) | 26/05/2026 | 28/05/2026 | 3 | | Onboarding flow | Done |
| **3** | Hiển thị danh sách món ăn | 27/05/2026 | 28/05/2026 | 2 | | Recipe listing | Done |
| **3** | Xây dựng API gợi ý thực đơn bằng AI | 28/05/2026 | 30/05/2026 | 3 | | AI meal plan API | Done |
| **3** | Xây dựng màn hình kế hoạch ăn trong tuần | 29/05/2026 | 31/05/2026 | 3 | | Meal plan screen | In progress |
| **3** | Test module đăng nhập & onboarding | 30/05/2026 | 31/05/2026 | 2 | | Auth testing | Planned |
| **3** | Hoàn thiện báo cáo kế hoạch 10 tuần | 29/05/2026 | 31/05/2026 | 3 | | 10-week plan | In progress |
| **4** | Nhập dữ liệu kho món ăn Việt Nam (~100 món) | 01/06/2026 | 03/06/2026 | 3 | | Recipe catalog | Planned |
| **4** | Kiểm tra dữ liệu trước khi đưa lên server | 03/06/2026 | 03/06/2026 | 1 | | Data validation | Planned |
| **4** | Cập nhật cấu hình gói Free / Premium trên server | 03/06/2026 | 04/06/2026 | 2 | | Subscription setup | Planned |
| **4** | Kiểm thử chức năng gợi ý thực đơn (nội bộ) | 04/06/2026 | 06/06/2026 | 3 | | Meal plan testing | Planned |
| **4** | Tạo bản cài thử nghiệm (APK) | 06/06/2026 | 07/06/2026 | 2 | | Test build | Planned |
| **4** | Khảo sát khách hàng & đối thủ (báo cáo môn học) | 01/06/2026 | 07/06/2026 | 7 | | Survey document | Planned |
| **5** | **Triển khai hệ thống lên môi trường thật** | 08/06/2026 | 09/06/2026 | 2 | | **Production deploy** | Planned |
| **5** | Cập nhật database & API AI trên server production | 08/06/2026 | 09/06/2026 | 2 | | Server migration | Planned |
| **5** | Phát hành bản MVP cho người dùng thử | 09/06/2026 | 10/06/2026 | 2 | | MVP release | Planned |
| **5** | Thu thập phản hồi MVP & USP | 10/06/2026 | 12/06/2026 | 3 | | Feedback summary | Planned |
| **5** | Sửa lỗi nghiêm trọng sau triển khai | 11/06/2026 | 13/06/2026 | 3 | | Bug fixing | Planned |
| **5** | Test luồng sử dụng chính sau triển khai | 13/06/2026 | 14/06/2026 | 2 | | Deploy testing | Planned |
| **6** | Xây dựng giới hạn đổi món theo gói (Free / Premium) | 15/06/2026 | 17/06/2026 | 3 | | Swap limits | In progress |
| **6** | Xây dựng giới hạn làm mới thực đơn AI | 16/06/2026 | 17/06/2026 | 2 | | Refresh limits | In progress |
| **6** | Thiết kế giao diện gói Free (3 ngày) & Premium (7 ngày) | 17/06/2026 | 19/06/2026 | 3 | | Premium UI | In progress |
| **6** | Test module gói Free / Premium | 19/06/2026 | 20/06/2026 | 2 | | Freemium testing | Planned |
| **6** | Cập nhật persona & kế hoạch marketing (báo cáo) | 15/06/2026 | 21/06/2026 | 7 | | Marketing doc | Planned |
| **7** | Hoàn thiện danh sách mua sắm từ thực đơn | 22/06/2026 | 24/06/2026 | 3 | | Shopping list | Planned |
| **7** | Hoàn thiện chế độ nấu ăn từng bước | 24/06/2026 | 26/06/2026 | 3 | | Cooking mode | Planned |
| **7** | Tìm kiếm & lọc món ăn | 25/06/2026 | 27/06/2026 | 3 | | Search feature | Planned |
| **7** | Test các module phụ trợ | 27/06/2026 | 28/06/2026 | 2 | | Module testing | Planned |
| **8** | Tối ưu tốc độ tải dữ liệu món ăn | 29/06/2026 | 30/06/2026 | 2 | | Performance tuning | Planned |
| **8** | Tối ưu API gợi ý thực đơn AI | 30/06/2026 | 01/07/2026 | 2 | | API optimization | Planned |
| **8** | Chỉnh sửa giao diện theo phản hồi MVP | 01/07/2026 | 03/07/2026 | 3 | | UI improvements | Planned |
| **8** | Test hiệu năng | 03/07/2026 | 04/07/2026 | 2 | | Performance testing | Planned |
| **8** | Lập bảng chi phí vận hành (AI, server) | 29/06/2026 | 05/07/2026 | 7 | | Cost report | Planned |
| **9** | Kiểm thử tích hợp toàn hệ thống | 06/07/2026 | 08/07/2026 | 3 | | Integration testing | Planned |
| **9** | Kiểm tra bảo mật dữ liệu người dùng | 08/07/2026 | 09/07/2026 | 2 | | Security review | Planned |
| **9** | Sửa lỗi tích hợp | 09/07/2026 | 11/07/2026 | 3 | | Bug fixing | Planned |
| **9** | Test end-to-end | 11/07/2026 | 12/07/2026 | 2 | | E2E testing | Planned |
| **10** | Kiểm thử tổng thể trước nộp đồ án | 13/07/2026 | 14/07/2026 | 2 | | Final testing | Planned |
| **10** | Sửa lỗi cuối cùng | 14/07/2026 | 15/07/2026 | 2 | | Final bug fix | Planned |
| **10** | Chuẩn bị slide báo cáo | 15/07/2026 | 16/07/2026 | 2 | | Presentation slide | Planned |
| **10** | Demo và nghiệm thu đồ án | 17/07/2026 | 19/07/2026 | 3 | | Project demo | Planned |

---

## Tóm tắt theo tuần (ai cũng đọc được)

| Tuần | Thời gian | Mục tiêu chính |
|:----:|-----------|----------------|
| **1** | 11/05 – 17/05 | Hiểu yêu cầu, vẽ use case & luồng hệ thống |
| **2** | 18/05 – 24/05 | Chọn công nghệ, thiết kế database & giao diện sơ bộ |
| **3** | 25/05 – 31/05 | Làm nền tảng app: đăng nhập, hồ sơ, danh sách món, gợi ý thực đơn AI |
| **4** | 01/06 – 07/06 | Chuẩn bị dữ liệu, test kỹ, build thử — **sẵn sàng triển khai** |
| **5** | 08/06 – 14/06 | **TRIỂN KHAI MVP** + thu feedback (Outcome 2) |
| **6** | 15/06 – 21/06 | Gói Free / Premium & giới hạn sử dụng |
| **7** | 22/06 – 28/06 | Mua sắm, nấu ăn, tìm kiếm món |
| **8** | 29/06 – 05/07 | Tối ưu tốc độ & giao diện, báo cáo chi phí |
| **9** | 06/07 – 12/07 | Test tích hợp & bảo mật |
| **10** | 13/07 – 19/07 | Test cuối, slide, **demo nghiệm thu** (không triển khai mới) |

---

## Tiến độ thực tế (27/05 — Tuần 3)

| Đã xong | Đang làm | Tuần 4–5 cần làm |
|---------|----------|------------------|
| Phân tích, ERD, wireframe | Màn hình kế hoạch ăn | Nhập ~100 món lên server |
| Đăng nhập, onboarding | Báo cáo 10 tuần | Test đầy đủ trước triển khai |
| API AI gợi ý thực đơn | | **Triển khai Tuần 5** |
| Danh sách món cơ bản | | Thu feedback MVP |

---

## Ghi chú

- Mỗi chức năng lớn đều có dòng **Test …** riêng (giống mẫu báo cáo nhóm).
- Chi tiết kỹ thuật triển khai (checklist, lệnh test): xem `WEEK4_PRE_DEPLOY_CHECKLIST.md`, `WEEK5_QA_CHECKLIST.md` — **không** đưa vào bảng chính để báo cáo dễ đọc.
- Tính năng để sau đồ án (không ảnh hưởng Tuần 5): thanh toán in-app thật, chatbot dinh dưỡng, kho món Premium hàng trăm món.

---

## Phiên làm việc chính (Responsive + Performance)

Đây là trục kỹ thuật bắt buộc chạy song song với UI mới, không để dồn về cuối:

| Tuần | Công việc chính về responsive/performance | Kết quả mong đợi |
|:----:|-------------------------------------------|------------------|
| **4** | Chuẩn hóa layout responsive cho màn chính (Auth, Home, Meal Plan): breakpoints mobile/tablet, max-width, padding động | UI không vỡ trên màn 360–1024px |
| **5** | Đo hiệu năng MVP trước/sau deploy (jank, frame time, thời gian load màn) + tối ưu luồng mở app/home/meal plan | Demo MVP mượt, không giật ở luồng chính |
| **6** | Tối ưu render các list/card có cập nhật thường xuyên (provider rebuild scope, const widget, map lookup) | Giảm rebuild không cần thiết |
| **7** | Tối ưu ảnh và danh sách dài (cache, placeholder nhẹ, lazy loading) cho shopping/search/cooking | Cuộn danh sách ổn định trên máy tầm trung |
| **8** | Profiling tổng thể (Flutter DevTools), tối ưu memory và startup time, chốt checklist release hiệu năng | Bản release đạt baseline trước UAT |
| **9-10** | Regression test responsive + performance trước nghiệm thu | Không phát sinh lỗi vỡ UI/giật lag lớn |

---

*Copy bảng trên sang Excel → merge cột **Tuần** theo từng nhóm 1–10 → điền **Người phụ trách**.*

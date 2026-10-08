# GraphFlow — Blueprint & Handoff Doc

## Overview
Mobile-first web app สำหรับจัดการงานกราฟิกในทีม 2-5 คน
ออกแบบให้เปิดผ่าน LINE Rich Menu ได้ทันที — Single HTML File

---

## Stack
| Layer | Tech |
|---|---|
| Frontend | Vanilla HTML / CSS / JS (no framework) |
| Icons | Tabler Icons v3.19 (CDN) |
| Storage | localStorage (client-side) |
| Database | ไม่ใช้ — ถ้าต้องการ sync ทีม → Supabase |
| Deploy | Vercel Static / Netlify |
| Repo | GitHub → `Droif` |

---

## File Structure
```
droif/
├── index.html      ← single file app (all-in-one ~104KB)
├── vercel.json     ← deployment config
└── README.md       ← this file
```

---

## Features (8 หน้า)

| # | หน้า | Tab | คำอธิบาย |
|---|---|---|---|
| 1 | กระดาน | งาน | สร้าง / ดู / กรอง task cards |
| 2 | KPI | KPI | คะแนนรายคน + อันดับทีม + ดาว |
| 3 | Timeline | Timeline | Funnel คอขวด + timeline รายงาน |
| 4 | กิจกรรม | กิจกรรม | Activity log ทุก action |
| 5 | ทีม | ทีม | โปรไฟล์ + งานเสร็จรายคน |
| 6 | แจ้งทีม | แจ้งทีม | Broadcast นัด / งาน / เตือน + แนบลิงก์ |
| 7 | ส่งออก | ส่งออก | Export CSV / Activity log |
| 8 | แจ้งเตือน | แจ้งเตือน | Mention + feedback + broadcast |

---

## Data Model (localStorage key: `gf_mob_v1`)

```js
db = {
  members: [
    { id, name, cls, init, role }
    // role: 'designer' | 'lead' | 'boss'
  ],
  tasks: [
    {
      id, name, client,
      assignees: [name, ...],   // หลายคนได้
      due, priority,            // 'normal' | 'high'
      status,                   // ดูด้านล่าง
      step,                     // 0-5
      note,
      links: [{ id, name, url, addedBy, time }],
      comments: [{ id, author, type, text, mention, time, resolved }],
      log: [{ time, user, action, icon, color }]
    }
  ],
  broadcasts: [
    {
      id, type,                 // 'meet'|'task'|'remind'|'info'
      from, to: [name, ...],
      subject, message,
      date, time,
      links: [{ label, url, icon, color, bg }],
      readBy: [name, ...],
      time_sent
    }
  ],
  activityLog: [
    { id, actor, action, target, taskId, type, time }
  ],
  nextId, nextCid, nextLid, nextAid
}
```

---

## Task Status Flow
```
new → wip → review → approved → done
        ↓              ↓
     blocked        rejected
        ↓
       wip (unblock)
```

| Status | สี | ไอคอน |
|---|---|---|
| new | น้ำเงิน | 📥 inbox |
| wip | ส้ม | 🖌 brush |
| blocked | แดง | 🔒 lock |
| review | ม่วง | 👁 eye |
| approved | เขียว | ✅ check |
| done | เขียวเข้ม | ✓ check |

---

## KPI Formula
```
score = (completionRate × 0.35)
      + (onTimeRate    × 0.35)
      + (qualityRate   × 0.30)
      - (blocked       × 8)

qualityRate = max(0, 100 - openFeedback × 10)

Grade:
  90-100 → ดีเยี่ยม ★★★★★
  75-89  → ดี       ★★★★
  60-74  → พอใช้    ★★★
  45-59  → ต้องปรับปรุง ★★
  0-44   → ต่ำกว่าเกณฑ์  ★
```

---

## Broadcast Types
| type | emoji | สี |
|---|---|---|
| meet | 🗓 | เขียว |
| task | 📋 | น้ำเงิน |
| remind | ⏰ | ส้ม |
| info | 📢 | ม่วง |

Link auto-detect: Google Meet, Zoom, Drive, Figma, Notion, Canva, LINE, MS Teams

---

## Deploy Process
1. `git push` → GitHub repo **Droif** (branch: `main`)
2. Connect Vercel → import repo → auto deploy
3. ได้ URL เช่น `https://graphflow.vercel.app`
4. ใส่ URL ใน LINE Rich Menu → Action: Open URL

### ถ้าต้องการ Multi-user Sync (ข้อมูลร่วมกันทั้งทีม)
- เพิ่ม **Supabase** — table: `tasks`, `members`, `broadcasts`, `activity_log`
- Replace `localStorage` → Supabase JS client
- Auth: Supabase Auth (email หรือ LINE Login)

---

## Next Steps (ถ้าจะพัฒนาต่อ)
- [ ] Supabase realtime sync — ทีมเห็นข้อมูลเดียวกัน
- [ ] LINE Notify / LINE Messaging API — push แจ้งเตือนเข้า LINE จริง
- [ ] File upload — แนบไฟล์จริงแทน URL
- [ ] PWA — ติดตั้งเป็น app บนมือถือได้
- [ ] Role permission — boss เท่านั้นที่ approve ได้

---

## Commit Info
```
Branch : main
Commit : 🚀 Initial deploy: GraphFlow v1.0
Files  : index.html (104KB), vercel.json, README.md
Tests  : 10/10 passed
```

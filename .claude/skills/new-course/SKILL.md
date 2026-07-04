---
name: new-course
description: Invoked when the user says "start a course" (or asks to set up / scaffold a new course folder for an outside course — a MOOC, university program, vendor academy). Creates the course spoke — folder + Course Tutor CLAUDE.md from the canonical template — optionally writes _course.md from a pasted syllabus, and registers the course in learning-path.md via the advisor.
---

# New course — scaffold a course spoke

Trigger: **"start a course"** — run from the hub. After the scaffold, all
tutoring happens inside the new folder (open Claude Code there).

## Steps

1. **Get the essentials** (ask only for what wasn't given): course name,
   provider, and a short folder name (lowercase, hyphenated). Folder lives at
   `notes/<folder>/`.

2. **Scaffold:**
   - Create the folder.
   - Copy the canonical Course Tutor file:
     `.claude/templates/course-CLAUDE.md` → `notes/<folder>/CLAUDE.md`.
     (Copy — do not rewrite or customize; it is identical in every course
     folder by design.)

3. **Syllabus, if in hand:** if the user can paste the syllabus (or point at a
   URL) now, write `_course.md` in the standard Course Profile format. If not,
   skip — the first spoke session asks for it.

4. **Register with the advisor** (Agent tool, `subagent_type: advisor`): report
   the new course (name, provider, folder, goal) so it lands in the
   `## Courses` section of `learning-path.md`. Relay the advisor's summary.

5. **Hand off:** the spoke is ready — start tutoring by opening Claude Code
   inside the folder. Spoke magic words: *quiz me · fill my gaps · promote to
   my vault*.

## Rules

- Commit the new folder (`course: scaffold <name>`) and push.
- Never copy the Course Tutor file from another course folder (drift risk);
  the template in `.claude/templates/` is the single source.
- Course folders keep their own conventions — never impose the vault schema.
- **Copyright note:** course notes summarizing paid/licensed material stay in
  this private repo — never publish them.

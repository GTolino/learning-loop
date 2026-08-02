---
name: new-course
description: Invoked when the user says "start a course" (or asks to set up / scaffold a new course folder). Creates the course spoke — folder + Course Tutor CLAUDE.md from the canonical template — optionally writes _course.md from a pasted syllabus, and registers the course in learning-path.md via the advisor so it is visible to the roadmap from day one.
---

# New course — scaffold a course spoke

Trigger: **"start a course"** — run from the hub. After the scaffold, all
tutoring happens inside the new folder (open Claude Code there), like the
existing course folders spokes.

## Steps

1. **Get the essentials** (ask only for what wasn't given): course name,
   provider, and a short folder name (lowercase, hyphenated — e.g.
   `anthropic-academy`). Folder lives at `notes/<folder>/`.

2. **Scaffold:** copy **both** canonical templates — do not rewrite or customize
   either; they are identical in every course folder by design.
   - Create the folder.
   - `.claude/templates/course-CLAUDE.md` → `notes/<folder>/CLAUDE.md`
   - `.claude/templates/course-settings.json` →
     `notes/<folder>/.claude/settings.json`
     ⚠ **Not optional.** A spoke started without this gets no SessionStart hook at
     all — settings come from the folder Claude Code is launched in, and the hub's
     never load. Skipping it is a silent failure: the course dashboard just never
     appears. (Both existing course folders spokes ran that way for weeks.)

3. **Syllabus, if in hand:** if the user can paste the syllabus (or point at a
   URL) now, write `_course.md` in the standard Course Profile format (see the
   template's own instructions). If not, skip — the first spoke session asks
   for it.

4. **Register with the advisor** (Agent tool, `subagent_type: advisor`): tell
   it a new course started (name, provider, folder, goal) so it adds the entry
   to the `## Courses` section of `learning-path.md` and connects it to goals.
   Relay the advisor's summary.

5. **Hand off:** tell the user the spoke is ready — start tutoring by opening
   Claude Code inside the folder. Remind them of the spoke magic words:
   *quiz me · fill my gaps · promote to my vault*.

## Rules

- The vault is a git repo — commit the new folder
  (`course: scaffold <name>`) and push, matching the scribe convention.
- Never copy the Course Tutor file from another course folder (drift risk);
  the template in `.claude/templates/` is the single source.
- Course folders keep their own conventions — never impose the hub note schema.

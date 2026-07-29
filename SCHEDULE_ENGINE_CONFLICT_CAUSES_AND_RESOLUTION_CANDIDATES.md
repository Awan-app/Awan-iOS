# Schedule Conflict Causes and Resolution Candidates

This document describes the business situations that can prevent Awan from
placing a task safely and the resolution choices that may be offered to the
user.

## Scheduling principles

- Completed work and time manually fixed by the user are protected.
- Awan may automatically use free time inside the task's selected zone.
- Awan does not silently move protected time.
- Splitting a task, extending beyond its zone, or using a future day requires
  the user's approval.
- Dependent tasks must remain after the work they depend on.

## Primary conflict causes

### 1. The task has no zone

Awan cannot automatically place a task when the task has no scheduling zone.

Resolution candidates:

- Assign a zone and try scheduling again.
- Leave the task unscheduled for now.

### 2. A required task is not fully scheduled

A task cannot be placed when one or more of its dependencies do not yet have
enough scheduled time to be completed.

This may happen when the required task:

- Has not been scheduled.
- Is only partially scheduled.
- Has its own unresolved scheduling conflict.
- Was missed and now puts the rest of a dependency chain at risk.

Resolution candidates:

- Resolve and schedule the required task first.
- Shift the affected dependency chain to a later day.
- Place the missed task and its successor in the same time period.
- Remove the dependency and make the successor independent.
- Leave the conflict unresolved for now.

### 3. The task does not fit in today's zone

The task's remaining duration cannot fit into one free period inside today's
selected zone.

This can be caused by:

- The zone having fewer free minutes than the task requires.
- Existing sessions consuming part of the zone.
- Other unavailable time consuming part of the zone.
- Free time being divided into gaps that are individually too short.
- A dependency forcing the task to start later.

Possible resolution candidates:

- Split the task across today's free periods.
- Start inside the zone and finish after the zone ends.
- Complete part today and the rest on a future day.
- Move the entire remaining task to the next available day.
- Leave the task unresolved for now.

Not every candidate is always available. Awan only offers candidates that can
produce a valid schedule.

## Candidate eligibility

### Split within today

This candidate is available when:

- The task allows splitting.
- Today's free periods can hold all remaining work together.
- At least two sessions are needed.
- Every resulting session meets the minimum allowed session duration.

Business impact:

- The task is completed today.
- The task appears as multiple sessions.

### Continue past the zone

This candidate is available when:

- The task can start in free time inside its zone.
- It can continue beyond the zone without overlapping occupied time.

Business impact:

- The task remains one session.
- The session finishes later than the selected zone normally allows.

### Split across days

This candidate is available when:

- The task allows splitting.
- A valid portion can be completed today.
- The remainder fits on a future available day.
- Both portions meet the minimum allowed session duration.

Business impact:

- The task is divided into multiple sessions.
- Part of the work moves to a future day.

### Schedule on the next available day

This candidate is available when the full remaining task fits into one free
period on a future day within Awan's scheduling horizon.

Business impact:

- No part of the remaining work is scheduled today.
- The task moves to the first future day where it fits, which may not be
  tomorrow.

## Existing-session conflicts

### Two sessions overlap

Two sessions occupy the same time.

Resolution candidates:

- Keep the overlap.
- Move the first session so it ends when the second begins.
- Move the second session so it begins when the first ends.

### Protected time is longer than the task

The task duration is reduced until it becomes shorter than its completed work
plus its manually fixed sessions.

Resolution candidates:

- Keep the extra protected time.
- Trim or remove the latest fixed time until the schedule matches the task,
  when completed history can still be preserved.

Completed history is never trimmed.

### Fixed sessions fall outside a newly selected task zone

The task's zone changes, but one or more manually fixed sessions are outside the
new zone.

Resolution candidates:

- Keep the fixed times outside the zone.
- Move the affected sessions into available time inside the new zone.
- Undo the zone change and restore the previous task zone.

### A zone change leaves sessions outside the zone

A zone's hours are changed and sessions associated with it no longer fall
inside the updated hours.

Resolution candidates:

- Keep the sessions where they are.
- Replan the affected sessions inside the updated zone.
- Undo the zone change.

## Conflict priority

When several conflicts affect the same task, Awan handles them in this order:

1. Protected time exceeds the task duration.
2. Fixed sessions fall outside a newly selected task zone.
3. A dependency is unavailable.
4. The remaining task work does not fit.

Only the first unresolved conflict is presented at a time. Resolving it may
change or remove the conflicts that follow.

## User approval and safeguards

- Automatically placed sessions may use safe free time inside today's zone.
- Every alternative that splits work, extends a zone, or uses a future day is
  presented before it is applied.
- Future-day suggestions remain proposals until the user selects one.
- Manually fixed sessions remain protected unless the user explicitly chooses
  to move or trim them.
- If no valid resolution candidate exists, the task remains unresolved rather
  than being forced into an unsafe schedule.

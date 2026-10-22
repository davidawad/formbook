# Direct-push landing from box finalize

When a repository's `automation-control.json` sets `landing.mode` to
`direct-push`, a successful box run must land its finalized commit on the
repository's default branch. Publishing only `newbox/<run>` leaves the work
stranded because these repositories do not have a land-queue consumer.

## Finalize contract

After staging, the repository's configured quality command has succeeded, and
the final commit has been created:

1. Read the configured default branch and landing mode from the repository
   policy. Do not infer direct-push from a missing or unreadable policy.
   Resolve and run the repository's configured quality command using the
   captured repository policy; a missing or failing command makes finalize
   fail before any default-branch push.
2. Fetch the default branch from the captured origin URL. Do not trust an
   agent-modified remote or a stale local tracking ref.
3. Confirm the finalized commit descends from the fetched default-branch tip.
   If it does not, report a landing conflict and preserve the task branch.
4. Push the finalized commit to the default branch with a fast-forward-only
   update. Never force-push. Verify the remote branch tip equals the finalized
   commit before reporting success.
5. Publish the run's task branch as recovery evidence before attempting the
   default-branch push. If that publication fails, do not attempt landing. A
   failed direct push must leave the already-published task branch available
   and must make the run fail visibly; it must not be reported as landed.

Do not attempt direct landing for agent failures, an empty diff, a missing,
failed or unavailable required quality command, or a failed finalize. Existing
`box_ship` repositories continue through the box-ship path, and land-queue
repositories continue publishing their task branch for the lander.

## Acceptance checks for the runner change

Exercise finalize and publish against a local bare Git remote, without writing
to a real default branch:

- A direct-push policy fast-forwards the configured default branch to the
  finalized commit, verifies that remote tip, and still publishes the task
  branch.
- A default branch that advanced by a commit outside the task's ancestry is
  rejected without changing that branch; the task branch remains published.
- A transport failure, rejected update, or remote-tip mismatch is reported as
  a failed landing and preserves the task branch.
- A task-branch publication failure prevents the default-branch push; a later
  default-branch push failure leaves the published task branch available.
- An agent failure, empty diff, missing/failed quality command, unreadable
  policy, or a non-direct landing mode does not push the default branch.
- Re-running after the default branch already points at the finalized commit
  succeeds idempotently.

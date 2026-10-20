# Credential handling

## Remaining payment credential cleanup

- Removed embedded merchant/operator passwords, dormant alternative credentials, SDK password comments and sensitive HTTP logging. Call `configureOperator(name:password:)` with fresh test credentials before using the sample.
- The checked-in SDK copy is patched locally; reinstalling old Pods may restore the removed material. Historical passwords remain in Git history.

This cleanup removes the identified values/artifacts from the current branch. It does not revoke server accounts, rotate deployed device keys, rewrite Git history, remove old tags/releases, or automatically resolve scanner alerts. Treat previously published usable credentials as exposed and have their owners revoke or rotate them. Use new, narrowly scoped test credentials if development resumes.

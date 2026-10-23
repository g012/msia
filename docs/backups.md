# Backup and restore guidance

The database contains personal data and is the source of demand/consent records. Active Storage files are separate and require their own backup. A Docker volume is persistence, not a backup.

- Take daily PostgreSQL custom-format logical backups with `pg_dump -Fc`, and a matching snapshot/copy of the `msia_storage` volume. Use PostgreSQL client tools compatible with the server (17 in the template).
- Supply connection settings through a secret manager using `PGHOST`, `PGPORT`, `PGUSER`, `PGDATABASE` and `PGPASSWORD` / a protected `PGPASSFILE`; avoid embedding passwords in command arguments. Run from a trusted host on the private network or via `kamal accessory exec db` as appropriate. Do not publish the database port.
- Encrypt backups before leaving the host (for example with your chosen encrypted backup tool), store offsite with separate access credentials, monitor successful completion, and alert on missed jobs. Keep the encryption recovery material separately from the host.
- Suggested starting retention: seven daily plus four weekly snapshots, no older than 30 days, reviewed against the actual privacy policy. Limit access to the project operator; do not store raw dumps in this repository.
- Rehearse restore before accepting real signups: create an isolated database, `pg_restore --no-owner --no-acl`, restore the file snapshot with correct UID/GID 1000, boot the same application release, run migrations and inspect record counts and images. Keep outbound email disabled in the isolated restore environment.
- After restoring an older snapshot, reapply erasure/unsubscribe requests since that snapshot and run `RetentionJob`. Never let restored data silently reactivate subscriptions. Maintain an operator procedure for this; old backups are not a new marketing list.
- Document recovery point and recovery time targets. Confirm that access to the app secret key, registry, SMTP configuration and DNS can be recovered without putting secrets in Git.

Example on a trusted backup machine after configuring the PG environment:

```sh
umask 077
pg_dump --format=custom --no-owner --file=/secure-backups/msia.dump
# Encrypt and transfer with the backup system you selected, then remove the plaintext copy.
```

These commands are guidance; no production database, remote host, bucket or backup destination is assumed to exist.

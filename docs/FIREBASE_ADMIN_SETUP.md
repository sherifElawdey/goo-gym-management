# Firebase Admin Setup (Goo GYM)

## Why you saw `permission-denied`

Firestore rules previously required an `admins/{uid}` document **before** you could read `admins/{uid}` — impossible for new users.

Updated rules in `firestore.rules` allow:

- Signed-in users to read **their own** `admins/{uid}` document
- **One-time bootstrap** to create the first owner admin

## Step 1 — Deploy rules (required)

```bash
cd "/Volumes/sherif/projects/goo gym"
firebase deploy --only firestore:rules
```

If Firebase CLI is not initialized:

```bash
firebase login
firebase use --add
firebase deploy --only firestore:rules
```

## Step 2 — Create Firebase Auth user

In [Firebase Console](https://console.firebase.google.com) → **Authentication** → **Users** → **Add user**

- Email: `owner@yourgym.com`
- Password: (strong password)

## Step 3 — Create admin (choose one)

### Option A — In the app (recommended)

1. Run the app and sign in with the new user.
2. You will see **Create Owner Admin**.
3. Tap **Create Admin (Full Access)**.

This creates:

- `admins/{uid}` with `role: admin`, `permissions: full`
- `gym_config/app` bootstrap marker

### Option B — Firebase Console (manual)

1. Sign in once in the app (or note the user **UID** from Authentication).
2. Firestore → **Start collection** `admins` → Document ID = **UID**
3. Fields:

| Field | Type | Value |
|-------|------|-------|
| id | string | same UID |
| email | string | owner@yourgym.com |
| role | string | admin |
| permissions | string | full |
| createdAt | timestamp | now |

4. Create collection `gym_config` → document `app`:

| Field | Type | Value |
|-------|------|-------|
| bootstrappedBy | string | same UID |
| bootstrappedAt | timestamp | now |
| gymName | string | Goo GYM |

## Roles

| Role | Access |
|------|--------|
| `admin` | Full access (all modules + manage staff) |
| `staff` | Day-to-day operations (members, attendance, finance) |

To add staff later, an existing **admin** creates `admins/{staffUid}` with `role: staff` in Firestore (or via a future in-app screen).

## Verify

After setup, sign in again — you should reach the main dashboard without errors.

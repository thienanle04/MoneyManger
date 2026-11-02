# Local-first, no backend

Money Manager is one Flutter app with on-device SQLite. There is no REST API and no auth server, because this is a private offline-first cockpit and a sync backend was premature. A hosted backend (Firebase or otherwise) comes back only if multi-device sync or a shared household budget is required. Mobile is the product; web and desktop are not the target.

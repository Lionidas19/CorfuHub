# VS Code Launch Configuration Guide

This workspace includes pre-configured launch configurations for all three CorfuHub apps.

## 📋 Available Configurations

### User App (ch-user-app)
- **User App (Local)** - Mobile app with local Supabase (localhost:54331)
- **User App (Staging)** - Mobile app with staging database
- **User App (Production)** - Mobile app with production database

### Admin App (ch-admin-app)
- **Admin App (Local)** - Web app (Chrome) with local Supabase
- **Admin App (Staging)** - Web app with staging database
- **Admin App (Production)** - Web app with production database

### Owner App (ch-owner-app)
- **Owner App (Local)** - Web app (Chrome) with local Supabase
- **Owner App (Staging)** - Web app with staging database
- **Owner App (Production)** - Web app with production database

### Compound Configuration
- **All Apps (Local)** - Launch all 3 apps simultaneously against local Supabase

## 🚀 How to Use

### 1. Select Configuration
Press `F5` or click the **Run and Debug** icon in VS Code sidebar, then select a configuration from the dropdown.

### 2. For Local Development
Just select any "Local" configuration and press `F5`. The local Supabase anon key is pre-configured.

**Prerequisites:**
- Supabase CLI running: `npx supabase start` (in CorfuHub.CICD folder)
- Local Supabase should be accessible at `http://localhost:54331`

### 3. For Staging/Production

**First time setup:**
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and fill in your actual keys:
   ```bash
   STAGING_SUPABASE_URL=https://your-project.supabase.co
   STAGING_SUPABASE_ANON_KEY=eyJhbGc...
   PROD_SUPABASE_URL=https://your-prod-project.supabase.co
   PROD_SUPABASE_ANON_KEY=eyJhbGc...
   ```

3. Restart VS Code to load the environment variables

4. Select "Staging" or "Production" configuration and press `F5`

## 🔧 Configuration Details

Each launch configuration includes:
- `SUPABASE_URL` - Backend endpoint
- `SUPABASE_ANON_KEY` - Public anonymous key
- `ENV` - Environment label (local/staging/production)
- `SOURCE_PROJECT` - App identifier for audit logs

### Local Environment
- Uses hardcoded localhost URL and standard Supabase local JWT
- No environment variables needed

### Staging/Production
- Reads `SUPABASE_URL` and `SUPABASE_ANON_KEY` from `.env` file
- **Never commit `.env` to git** (already in .gitignore)

## 📱 Device Selection

### User App
By default launches on your default device. To change:
1. Open `.vscode/launch.json`
2. Add `-d` argument to User App configurations:
   ```json
   "-d", "chrome"           // Web
   "-d", "windows"          // Windows desktop
   "-d", "<device-id>"      // Specific mobile device
   ```

### Admin/Owner Apps
Pre-configured to launch in Chrome (`-d chrome`) as they're web-first apps.

## 🐛 Debug Mode Features

All configurations launch in debug mode, enabling:
- Breakpoints
- Hot reload (`r` in terminal)
- Hot restart (`R` in terminal)
- Step-through debugging
- Variable inspection

## 🔀 Compound Launch

The "All Apps (Local)" compound configuration launches all three apps simultaneously. Useful for testing cross-app workflows locally.

**Note:** Requires sufficient system resources (3 Flutter instances + local Supabase).

## 🛠️ Troubleshooting

### "Environment variable not found"
- Create `.env` file from `.env.example`
- Restart VS Code after editing `.env`

### "Cannot connect to Supabase"
- Local: Ensure `npx supabase start` is running
- Staging/Prod: Verify URLs and keys in `.env`

### Admin/Owner app won't launch
- Install Chrome if not available
- Change `-d chrome` to `-d edge` or another browser

### Port conflicts
- Local Supabase uses ports 54321-54328
- Check no other services are using these ports

## 📖 Reference

- [Flutter run command](https://docs.flutter.dev/tools/vs-code#running-and-debugging)
- [dart-define documentation](https://docs.flutter.dev/deployment/flavors)
- [Supabase local development](https://supabase.com/docs/guides/cli/local-development)

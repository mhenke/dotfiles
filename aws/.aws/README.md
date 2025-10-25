# AWS CLI Configuration

## ⚠️ CRITICAL SECURITY WARNING ⚠️
**NEVER commit AWS credentials to version control!**

## Stowed Files
- `config` - Region and output format preferences only

## NOT Stowed (Excluded via .stow-local-ignore)
- `credentials` - **AWS access keys** (LOCAL ONLY)
- `sso/` - SSO session tokens
- `cli/`, `cache/` - Cache directories

## Setup on New Machine
```bash
# After stowing config
aws configure
# Or for SSO:
aws configure sso
```

## If Credentials Leak
1. Immediately rotate keys: https://console.aws.amazon.com/iam/
2. Remove from git history: `git filter-branch` or BFG Repo-Cleaner
3. Check CloudTrail for unauthorized usage
4. Enable MFA on root account

## Verify Before Committing
```bash
cd ~/dotfiles
git status --ignored
# credentials should show as !! (ignored)
```

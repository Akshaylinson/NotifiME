@echo off
echo ============================================
echo  Git History Cleanup - Remove Large Files
echo ============================================
echo.

echo WARNING: This will rewrite Git history!
echo Make sure you have a backup before proceeding.
echo.
pause

echo.
echo Step 1: Creating backup branch...
git branch backup-before-cleanup
echo Backup created: backup-before-cleanup
echo.

echo Step 2: Removing large files from history...
echo.

REM Remove specific large files and directories from all commits
git filter-branch --force --index-filter ^
"git rm -r --cached --ignore-unmatch build/ .dart_tool/ assets/models/*.bin assets/models/*.tflite" ^
--prune-empty --tag-name-filter cat -- --all

echo.
echo Step 3: Cleaning up references...
git for-each-ref --format="delete %(refname)" refs/original | git update-ref --stdin
git reflog expire --expire=now --all

echo.
echo Step 4: Garbage collection...
git gc --aggressive --prune=now

echo.
echo ============================================
echo  Cleanup Complete!
echo ============================================
echo.
echo Repository size BEFORE and AFTER:
git count-objects -vH
echo.
echo Next steps:
echo 1. Test your repo: git log --oneline
echo 2. Force push: git push origin main --force
echo.
echo If something went wrong:
echo   git checkout backup-before-cleanup
echo.
pause

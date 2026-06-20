@echo off
echo Removing large files from Git...
echo.

REM Stop if push is in progress
echo Step 1: Removing files from current commit
git rm -r --cached build/ 2>nul
git rm -r --cached .dart_tool/ 2>nul
git rm --cached assets/models/gemma.bin 2>nul

echo.
echo Step 2: Adding cleaned files
git add .gitignore .gitattributes

echo.
echo Step 3: Committing changes
git commit -m "Remove large files and build artifacts from Git tracking"

echo.
echo Step 4: Cleaning up Git cache
git gc --aggressive --prune=now

echo.
echo Done! Now you can push with: git push --force-with-lease
echo.
echo WARNING: If you've already started pushing, cancel it (Ctrl+C) and run this script.
pause

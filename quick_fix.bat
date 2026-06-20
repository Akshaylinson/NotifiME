@echo off
echo ============================================
echo  Quick Fix: Reset to Clean Commit
echo ============================================
echo.

echo This will reset your local commits and recommit without large files.
echo Your files will NOT be deleted, only removed from Git tracking.
echo.
pause

echo.
echo Step 1: Checking current status...
git log --oneline -5
echo.

echo Step 2: Finding first commit with large files...
echo Resetting to commit BEFORE large files were added...
echo.

REM Reset to the origin/main (remote state)
git reset --soft origin/main

echo.
echo Step 3: Unstaging everything...
git reset

echo.
echo Step 4: Adding files according to .gitignore...
git add .
git status

echo.
echo Step 5: Ready to commit!
echo Review the files above. When ready, run:
echo   git commit -m "Clean commit without build artifacts and large models"
echo   git push origin main
echo.
pause

@echo off
cd /d "%~dp0"
echo Iniciando StudyAI com Gemini e Supabase...
flutter run -d chrome --dart-define=AI_ENDPOINT=https://abyivhafxbutmvgudktw.supabase.co/functions/v1/study-ai --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_SOOZgD8Lx2yPMhcyWazyBA_5QpODy4W
pause

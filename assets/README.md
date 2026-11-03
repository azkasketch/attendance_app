# Assets Directory

This directory contains static assets for the application.

## Required Assets

### Images (`assets/images/`)
- `ic_absen.png` - Icon for attendance record menu
- `ic_leave.png` - Icon for permission/leave menu  
- `ic_history.png` - Icon for attendance history menu

### Raw Files (`assets/raw/`)
- `face_id_ring.json` - Lottie animation for face detection scanning

## Instructions

1. Place the required image files in the `images/` folder
2. Place the Lottie animation JSON file in the `raw/` folder
3. You can download free icons from:
   - Flaticon: https://www.flaticon.com/
   - Icons8: https://icons8.com/
   - Material Design Icons: https://fonts.google.com/icons

4. For Lottie animations, visit:
   - LottieFiles: https://lottiefiles.com/
   - Search for "face scan" or "face id" animations

## Temporary Fallback

The app includes error handling to gracefully handle missing assets:
- Images will show a placeholder
- Lottie animations will show a text fallback if the JSON file is missing

# Ultrasound Fascia Layer Analysis (Digital Image Processing)

This project analyzes ultrasound DICOM images to detect fascia layers and measure their thickness using image processing techniques.

## Features
- Load and crop ultrasound DICOM images
- Speckle noise reduction (median + Gaussian filtering)
- Fascia layer segmentation using adaptive thresholding and active contours
- Thickness measurement via polynomial-smoothed boundaries
- Interactive MATLAB GUI with layer visualization and numeric results

## How to Run
1. Make sure all `.m` files are in the same folder (or on the MATLAB path)
2. In MATLAB, run:
   Ultrasound_GUI

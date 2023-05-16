+++
title = "Trouble with Timeseries"
date = 2023-05-16
description = "Problems due to different seeing conditions"
extra = {header_img = "https://live.staticflickr.com/65535/52900733642_1b37f47789_k_d.jpg"}
draft = false
+++

### **Problem statement**
OCCULT-2 traces out a number of features, many of which match throughout the timeseries. However, changes in the local seeing create inaccuracy with OCCULT in consecutive images, and prevent accurate detection of feature timelines. 

### **Supporting observations**
 Some lines dramatically lengthen as a result of OCCULT bridging multiple observations, or dramatically shorten. Many lines vanish and reappear after some time due to changes in local seeing. 

### **Expected or ideal outcomes**
Seeing should not affect changes so much. 

### **Hypotheses**
* There are transformations that may help reject background noise while emphasizing lines. It'll be important to maintain line length and quantity. 
    - See [https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7128047/#B27](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7128047/#B27) for method in retinal blood vessels
* OpenCV's contours method, or a generalized hough transform, could be used - but neither are as developed as OCCULT and may just result in worse results. 
* Look through Pythonic approaches to spicule identification and coronal loop identification. 
* We might be able to use Retinal Segmentation Techniques

### **Methods**

1. Use a tophat transform to bring out the smaller fibrils, and make them distinct against the background.
2. Use thresholding to get rid of background noise. OTSU thresh would be great if we can pull it off. 
3. Apply skeletonization to the thresholded image

### **Results**

1. Tophat transform

Without sharpening, kernel size = "Threshold (x) THT"
![Tophat transform nosharp](images/tophat-nosharp.png)

With sharpening
![Tophat transform](images/tophat.png)

Let's try without sharpening for now. Sharpening adds a lot of noise that we could do without. 

Skimage tophat:

![Tophat skimage](images/tophat_skimage.png)

Does this help?

2. Thresholding

Using skimage's thresholding techniques on th7, 

![Thresholding](images/thresholding.png)

Yeah. They look the same. Not much happening here. Let's try skipping this for now and going directly to skeletonization. 
+++
title = "Trouble with Timeseries"
date = 2023-05-16
description = "Problems due to different seeing conditions"
extra = {header_img = "https://live.staticflickr.com/65535/52900733642_1b37f47789_k_d.jpg"}
draft = false
+++

### Problem statement
OCCULT-2 traces out a number of features, many of which match throughout the timeseries. However, changes in the local seeing create inaccuracy with OCCULT in consecutive images, and prevent accurate detection of feature timelines. 

### Supporting observations
 Some lines dramatically lengthen as a result of OCCULT bridging multiple observations, or dramatically shorten. Many lines vanish and reappear after some time due to changes in local seeing. 

### Expected or ideal outcomes
Seeing should not affect changes so much - ideally, we can find a filter or set of filters that reduce the impact of seeing conditions. 

Below, I'll tinker around with skimage and OpenCV to see what we can get. 

### The Process

We're starting off with this base image:

![Base image](/images/work/base_image.png)

We need to bring out those individual fibular strands, and make them clearer. They're pretty indistinct as is, and blurry. If we sharpen the image with skimage's [unsharp mask](https://scikit-image.org/docs/stable/auto_examples/filters/plot_unsharp_mask.html) (`radius=1, amt=4.0`), we get something like this:

![Sharpened base image](/images/work/base_sharpened.png)

Better. Now - working on the entire image can get chaotic and force us to zoom in a lot. Let's focus on fibrils in a small sub-section - the bottom left has some distinct fibrils. 

![Sharpened base cropped](/images/work/base_sharp_cropped.png)

Now. We have a lot of background here - let's try some [thresholding techniques](https://scikit-image.org/docs/stable/auto_examples/applications/plot_thresholding_guide.html). **Otsu's method** is an advanced technique for this - it'll look at the histogram of the image, look for two peaks, and then create a threshold between two threshold "peak groups". [This GIF does a great job of visualizing it](https://upload.wikimedia.org/wikipedia/commons/3/34/Otsu%27s_Method_Visualization.gif). I superimposed the original image to ensure Otsu was correctly measuring out sections. 

![Otsu thresholded image](/images/work/otsu_thresh.png)

Otsu does an *okay* job at this, but some features are cut off. I subtracted a `0.05` offset to the threshold otsu found, which resulted in 

![Otsu corrected image](/images/work/otsu_thresh_cor.png)

Better. This offset added some background noise - but we can deal with that later. Now, we've got some distinct fibrils - if we try out OCCULT on it, 

![OCCULT-traced images](/images/work/otsu_occult.png)

Similar results, but without a lot of the more indistinct fibrils that may blend into the background in low-seeing conditions. While it does remove some fibrils, I think the tradeoff in removing low-confidence fibrils is worthwhile. 

Now, to try and make our fibrils a bit more distinct. skimage has an [awesome script to test out](https://scikit-image.org/docs/stable/auto_examples/edges/plot_ridge_filter.html#sphx-glr-auto-examples-edges-plot-ridge-filter-py) the variety of segmentation functions available to skimage. 

![Skimage variety of segmentation types](/images/work/skimage_segmentation.png)

I'll probably go near-sighted just trying to make out these little images. But, of the results, I'm liking the look of both Hessians and the Meijering with `sigma=1`. 

![Hessian and meijering filters](/images/work/hessian-meijering.png)

Let's go with the Hessian. We can deal with the large white blobs by just intersecting the image with the otsu tracing - leading to 

![Hessian segmentations](/images/work/hessians.png)

---

**Note**: Leaving this off for today because feeling hungry - tomorrow, let's see what we can do with the Hessian, and work to understand the underlying mathematics behind it.  

---
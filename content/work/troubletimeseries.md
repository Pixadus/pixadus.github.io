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

Let's go with the Hessian. Now - the Hessian matrix is a brilliant idea in image processing. If you've taken multivariable calculus or linear algebra before, you might remember it - mathematically, the Hessian can be represented as 

$$\vec{H}_f = \begin{bmatrix} \frac{\delta I^2}{\delta x^2} & \frac{\delta I^2}{\delta x\delta y} \\\ \frac{\delta I^2}{\delta y\delta x} & \frac{\delta I^2}{\delta y^2} \end{bmatrix}$$

In our context, this matrix describes the **second order intensity variations** around a given pixel. The eigenvalues of that Hessian matrix per pixel can then be used to evaluate the "local intensity curvature" - [this article does a much better job of explaining it](https://milania.de/blog/Introduction_to_the_Hessian_feature_detector_for_finding_blobs_in_an_image) than I can.  

We can deal with the large white blobs by just intersecting the image with the otsu tracing - leading to 

![Hessian segmentations](/images/work/hessians.png)

If we try out OCCULT-2 on this, 

![Occult on Hessian](/images/work/occult_hessian.png)

It's hard to say if it's better or worse. Many well-defined features are shared, some are lengthened, and some are gotten rid of entirely. Still - the entire goal of this tinkering was to reduce the impact of varied seeing conditions. If we try to compare the two timeseries now ...

![Slower comparison](/images/work/slow.gif)

Or, faster,

![Fast comparison](/images/work/fast.gif)

Graphing OCCULT-2 fibrils along this sequencee, 

![OCCULT-2 over timeseries (slow)](/images/work/occult-slow.gif)

Faster,

![OCCULT-2 over timeseries (fast)](/images/work/occult-fast.gif)

We see OCCULT recognizes many of the same fibrils and holds them relatively constant over time ... but many are extremely short lived, even where we can visually observe them still existing. In this scenario, it's likely OCCULT itself that is failing to recognize the existence of them.

This is ... *okay*. We could work with this. But, we're able to transform the image such that it has visibly consistent feature regions - having something more robustly able to detect these centerlines would be preferrable. 

## skimage segmentation

I played around with some of [skimage's segmentation methods](https://scikit-image.org/docs/stable/api/skimage.segmentation.html) (of which there's many). I achieved some good results with our base Hessian image through the MorphACWE (implemented as the **morphological Chan-Vese** algorithm in skimage), resulting in

![ACWE Segmentation](/images/work/acwe_segmentation.png)

And with the [find_contours](https://scikit-image.org/docs/stable/auto_examples/edges/plot_contours.html) method, 

![ACWE and contour methods](/images/work/acwe-contours.png)

MorphACWE creates more "normalized" areas by virtue of doing some image transformations to smooth out regions - the contour method, by contrast, finds *every* area where the image intensity goes from 0 -> 1, and makes a polygon out of it. 

I think we could achieve some good results by doing a contour evolution.

So, let's try to smooth the image out, "fattening" light regions. Let's try out a Gaussian first. 

![Gaussian hessian](/images/work/gausshess.png)

If we apply another Otsu filter to get back to a binary image, 

![Gaussian otsu](/images/work/gaussian-otsu.png)

If we start to plot our contours now, we see

![Gaussian contours](/images/work/gauss-cntrs.png)

Much smoother, and some previously non-joined fibrils are now joined. However - this is an issue as well, as now we have some close distinct fibrils that are now joined together, which we don't necessarily want. That said - let's try to calculate some centerlines through these by using the [label_centerlines library](https://github.com/ungarj/label_centerlines). 

**Note**: Offstage, I've been really trying to bring out every single visually identifiable fibril, which I really just don't think is possible with an algorithmic approach. Neural networks might do a bit better. But still, we'll try to work with this Gaussian contours setup. I think we can come up with something good. 

Okay. Label centerlines. This library is designed to work with [shapely Polygons](https://shapely.readthedocs.io/en/stable/reference/shapely.Polygon.html) - and our find_contours function just returns lists of points in (x,y) format, so polygon conversion is nice and easy.

![Label contours for both the base Hessian and gaussian version](/images/work/label_centerlines_hessgauss.png)

label_centerlines did exactly what we asked of it - but, there's some definite issues with **unrelated features** being joined (see left center) and some **single** features *not* being correctly joined (see bottom left).

We can try some [morphological transforms](https://scikit-image.org/docs/stable/api/skimage.morphology.html) to help with this. [Dilations](https://scikit-image.org/docs/stable/auto_examples/applications/plot_morphology.html#dilation) blow up light areas, while [erosions](https://scikit-image.org/docs/stable/auto_examples/applications/plot_morphology.html#erosion) reduce light areas. Focusing on the bottom left $(110\times90)$ px region,

![d1e1](/images/work/d1e1.png)

Great! Except, now ...

![d1e12](/images/work/d1e12.png)

![Luz](https://media.tenor.com/Vu4cdN5l0dQAAAAC/the-owl-house-luz.gif)

I know. I know! I ought to have expected it. Dilations will close small spaces, and will not distinguish between spaces between disconnected fibrils and separate features.
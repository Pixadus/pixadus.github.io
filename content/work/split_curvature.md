+++
title = "Splitting Curves"
date = 2023-06-12
description = "Splitting curves based on curvature."
extra = {header_img = "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fmedia1.tenor.com%2Fimages%2F153966444a731fabeef805f08abf3de6%2Ftenor.gif%3Fitemid%3D15755119&f=1&nofb=1&ipt=6f267753d0ece331a54896fe0d69868375ea213cd6bbb6c8834ec5960979ba8e&ipo=images"}
draft = false
+++

## The Problem

Traced-out fibrils are connected to one another, rather than being individual entities. 

## Ideal Result

Fibrils are long and have relatively small curvature values throughout the entire length of the fibril. 

## The Process

First, we present a selected set of combined fibrils that demonstrate this problem - 

![The Shape](/images/work/shape/initshape.png)

Let's try to visualize the curvature at every point. [Curvature](https://en.wikipedia.org/wiki/Curvature#Graph_of_a_function) can be defined for a parameterized curve as

$$
k = \frac{|x'y''-y'x''|}{\left(x'^2-y'^2\right)^{3/2}}
$$

For our parameterization, we have points separated by $t=0.5$, and $f(t) = (x(t),y(t))$. After working this calculation out in code, we get

![Curvature estimation 1](/images/work/shape/curv_est_1.svg)

It looks like it worked great! However, there are some points where the "rough terrain" along our curve increase local curvature where it shouldn't be. Let's smooth our data out by using a [Savitzky-Golay filter](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.savgol_filter.html) (with `win_size=20` & `deg=3` polynomial).

![Cuvature estimation 2](/images/work/shape/curv_est_2.svg)

Let's isolate these curvature extrema.

![Curvature extrema](/images/work/shape/curv_extrema.svg)

At this point, it'd be prudent to visualize what we'd ideally & realistically like this to turn into following curvature estimation. 

![Ideal](/images/work/shape/ideal_curv_extrema.svg)

I say "ideal" - though it isn't, as we see some fibrils cut off early. However, it's important to keep in mind *how* we go about this process. My thoughts are,

1. High-curvature areas should only match with curves across a **closed** shape (the line drawn between must lie inside the polygon, rather than outside). 
2. The closest ID'd matching curve must have some **minimum arc-length distance** away from the initial curve, to avoid matching along the initial curve or those beside it. 
3. When a shape is matched, get rid of nearby on-line identified curves to prevent **oversegmentation**. 

**Note**: Notice the blue line as well - we'll need to find a way to try preventing this. Also, need to specify a criterion for this high-curvature segmentation - minimum area? Don't want to segment everything. 

**Note 2**: Occam's razor says I'm overcomplicating this whole situation. It's something to keep in mind - but I want to try developing this method out today and tomorrow. Eventually, I might need to call a halt to it and just proceed with what we already have. 
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

Let's try to visualize the curvature at every point. [Curvature](https://openstax.org/books/calculus-volume-3/pages/3-3-arc-length-and-curvature) can be defined as 

$$
k = \Big\lVert \frac{d \boldsymbol{T}}{ds} \Big\rVert = | \boldsymbol{T}'(s)|
$$

where $d\boldsymbol{T}/ds$ is the change in the unit tangent vector per change in length. It can more easily be written 

$$
k=\frac{d\theta}{ds} = \frac{\theta_2-\theta_1}{ds}
$$

where $\theta = \arctan{\frac{dy}{dx}}$ and $ds$ is the Euclidian distance between two given points. Since points in our image are spaced at intervals of 0.5, let's check every four points for curvature. 
---
title: The Physicality of Software
layout: post
date: 2024/12/24
description: Building software that runs on faraway machines, for faraway users
tags: software hardware aws cloud
author: Aumit Leon
permalink: the-physicality-of-software
---
Years ago, during an internship in the summer of my Junior year of college, my manager and I sat down together to debug an issue we had with the execution of a workflow using [Step Functions](https://aws.amazon.com/step-functions/). That summer, our team had built and launched a workflow orchestration pipeline that would automate genomic analysis on microbes -- before launching this genomic pipeline, the analytical process our data scientists and bioinformaticians would perform was a hodge hodge of python scripts that ran outside of well curated virtual environments. Analysis was slow, painful, and manual. Before we launched our pipeline, our scientists were running hundreds of microbes through their workflows every quarter. [After launch, we were running hundreds of microbes through our pipeline every day](https://medium.com/indigoag-eng/leveraging-aws-to-scale-r-d-workflows-a200ffbf8ed6). 

This scale and automation is something only the cloud could have provided. And it was the cloud that my manager and I stared at, while trying to debug an error in our step function. We deployed code, pressed refresh, and awaited results -- we did this for what felt like an entire day. After hours of staring at the dull white backgrounds and text rendered in [Amazon Ember](https://developer.amazon.com/en-US/alexa/branding/echo-guidelines/identity-guidelines/typography), I sighed, and my manager looked at me and made a joke that was a little sad, but very true: 

> “This is what modern software development looks like, it’s clicking refresh in an AWS console.” 

The scale that our genomic pipeline unlocked was a direct application and success story of the cloud. Through AWS and a whole bunch of YAML, we were able to deploy parallelized workloads across fleets of machines in us-east-1. In our cozy office, nestled in an industrial park in [Hood Milk](https://hood.com/)’s old factory in Charlestown, all we had to do was press a button on our specced out MacBook Pros, and the jobs would run themselves. Not a single server rack on the premises. 

This is a pretty common experience for many modern software engineers. Our work is characterized by *scale*, achieved through the cloud, which is just a machine sitting in a datacenter in Virginia. The scope of what we can build has transformed along with the the tools we use to build. 

Spinning up a fleet of EC2 machines to run your app is trivial these days, and there are many tutorials that walk you through how to do it step by step. But in the extravagance of our tools, we have lost touch with the physicality of software. Our portal into this world is a cloud console, and maybe a terminal window if you SSH into a deployed machine. But we don’t hear the whir of fans on these machines, or the blinking lights of those physical consoles. We are far removed from the physicality of our work -- the machines that run our code, and the users that interact with the apps we write.

As a discipline, we really enjoy abstraction, so it’s comfortable to not think too deeply about the bare metal that our code is running on. That’s Amazon/Google/Microsft’s problem! We use lambdas and cloud functions and “serverless” compute. But there is always a machine, connected to a power supply, that needs to be maintained to ensure our software behaves the way we expect it to. We take for granted the power we yield, not just in the cloud but in our ever more powerful personal machines. 

Many of us are building things that run on faraway computers for faraway users that we will never see. It’s wonderful, powerful and a little bit sad. Distance erodes empathy. As our tools grow more powerful, the less efficient our application of them becomes -- everything becomes a nail to a hammer. To build bigger and more ambitious software, we’ll need to make better use of the tools we have today. Clicking buttons on the AWS console won’t go away, but we should aim to do so with more appreciation for what we can accomplish. 
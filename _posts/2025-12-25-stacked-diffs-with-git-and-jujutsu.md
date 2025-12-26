---
title: Stacked Diffs with Git and Jujutsu
layout: post
date: 2025/12/25
description: A talk I gave my team reguarding stacked diffs with Git and Jujutsu (jj)
tags: jj jujutsu software-engineering vcs git, stacked-diffs
author: Aumit Leon
permalink: stacked-diffs-with-git-and-jj
---

Below are the slides for a talk I presented to my team around stacked diffs with git and jj. 

<center>
<div style="position: relative; padding-bottom: 69.17%; height: 0; max-width: 600px; margin: 0 auto;">
  <iframe style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;" src="https://docs.google.com/presentation/d/e/2PACX-1vQgxHTlariuJGhf8ndxOE62yzlbZ4TH5DvZlZ2lk1--9hwgVe_Iot9A0hfi5h12tn5birSW0QSr1geE/pubembed?start=false&loop=false&delayms=3000" frameborder="0" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
</div>
</center>

I talk about how stacked diffs are effective tools for maintaining development momentum while also increasing velocity on code reviews. Stacked diffs prefer smaller, atomic commits, which are easier to review than larger commit(s). When reviewers can focus on a smaller set of changes, they can provide the highest quality review possible. Stacked diffs also ensure that engineers aren't bottlenecked by PR review cycle time, as they can continue to work on related downstream changes while awaiting feedback. Git makes stacked diff workflows quite difficult; since many of git's actions are very branch centric, this is incogruent with stacked diffs as stacking requires reasoning about changes *across* branches. I close by providing a practical walk through of using stacked diffs in git, and jj. 

This video is a practical walk through of stacked diffs:

<center>
<div style="position: relative; padding-bottom: 56.25%; height: 0; max-width: 600px; margin: 0 auto;">
  <iframe style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;" src="https://www.youtube.com/embed/Er3dqH-lloY?si=Zo_T2A_zKTsAMoj_" title="Stacked Diffs" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>
</center>


